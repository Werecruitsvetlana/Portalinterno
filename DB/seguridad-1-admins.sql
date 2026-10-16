-- =============================================
-- SEGURIDAD 1 — Solo las administradoras tienen acceso total
-- Ejecutar en: Supabase → SQL Editor → New query → Run
-- Correr ANTES de seguridad-2-cuentas-portal.sql
--
-- Antes: cualquier persona con sesión iniciada ("authenticated") tenía
-- acceso total a candidatos, empresas, facturas, banca, ternas, etc.
-- Después: solo las cuentas listadas en public.admins.
-- Es seguro correrlo más de una vez.
-- =============================================

-- 1. Tabla de administradoras (sin políticas: nadie la lee ni la cambia desde el navegador)
CREATE TABLE IF NOT EXISTS public.admins (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

INSERT INTO public.admins (user_id, email)
SELECT id, email FROM auth.users
WHERE lower(email) IN ('svetlana@werecruitdr.com', 'talent@werecruitdr.com')
ON CONFLICT (user_id) DO NOTHING;

-- 2. Función que usan las reglas y el login del portal de gestión
CREATE OR REPLACE FUNCTION public.es_admin() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.admins WHERE user_id = auth.uid());
$$;
GRANT EXECUTE ON FUNCTION public.es_admin() TO anon, authenticated;

-- 3. Cambiar cada regla "auth.role() = 'authenticated'" por "public.es_admin()"
--    (tablas y archivos). Si algo falla, no se cambia nada.
DO $$
DECLARE
  r record;
  patron text := 'auth\.role\(\)\s*=\s*''authenticated''(::text)?';
  nuevo_using text;
  nuevo_check text;
  sentencia text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.admins) THEN
    RAISE EXCEPTION 'No se encontraron las cuentas admin en auth.users. No se cambió nada.';
  END IF;

  FOR r IN
    SELECT * FROM pg_policies
    WHERE schemaname IN ('public', 'storage')
      AND (qual ~ patron OR with_check ~ patron)
  LOOP
    nuevo_using := regexp_replace(r.qual, patron, 'public.es_admin()', 'g');
    nuevo_check := regexp_replace(r.with_check, patron, 'public.es_admin()', 'g');
    sentencia := format('ALTER POLICY %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    IF nuevo_using IS NOT NULL THEN sentencia := sentencia || ' USING (' || nuevo_using || ')'; END IF;
    IF nuevo_check IS NOT NULL THEN sentencia := sentencia || ' WITH CHECK (' || nuevo_check || ')'; END IF;
    RAISE NOTICE '%', sentencia;
    EXECUTE sentencia;
  END LOOP;
END $$;

-- 4. Comprobación
-- a) Deben salir 2 filas (svetlana@ y talent@):
SELECT email FROM public.admins;

-- b) Debe salir VACÍO. Si sale alguna regla, avísale a Claude antes de seguir:
SELECT schemaname, tablename, policyname, roles, qual, with_check
FROM pg_policies
WHERE schemaname IN ('public', 'storage')
  AND (qual ILIKE '%authenticated%' OR with_check ILIKE '%authenticated%'
       OR 'authenticated' = ANY (roles));
