-- =============================================
-- SEGURIDAD 2 — Cuentas de empresas y candidatas con Supabase Auth
-- Ejecutar en: Supabase → SQL Editor → New query → Run
--
-- REQUISITOS:
--   1. Haber corrido seguridad-1-admins.sql.
--   2. En Supabase → Authentication → Sign In / Providers → Email:
--      "Confirm email" ACTIVADO (para que nadie se registre con un email ajeno).
--   3. Correrlo JUSTO cuando publiques los index.html nuevos de
--      werecruitdr.com y de We Recruit Women. El login viejo deja de funcionar
--      porque este script BORRA las columnas de contraseñas.
--
-- Cuentas que ya existían: se registran otra vez con el mismo email,
-- confirman el correo y su perfil (con sus vacantes) se vincula solo.
-- =============================================

-- 1. Vincular cada perfil con su cuenta de Supabase Auth
ALTER TABLE public.empresas_portal
  ADD COLUMN IF NOT EXISTS auth_uid uuid UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.perfiles_candidato
  ADD COLUMN IF NOT EXISTS auth_uid uuid UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL;

-- 2. Borrar las contraseñas guardadas en texto plano
ALTER TABLE public.empresas_portal DROP COLUMN IF EXISTS password;
ALTER TABLE public.perfiles_candidato DROP COLUMN IF EXISTS password;

-- 3. Devuelve el perfil de empresa de la cuenta con sesión.
--    Si no tiene, vincula uno viejo con el mismo email (solo con email confirmado)
--    o lo crea con los datos que dio al registrarse.
CREATE OR REPLACE FUNCTION public.mi_empresa_portal()
RETURNS SETOF public.empresas_portal
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  u auth.users;
  v_id uuid;
BEGIN
  SELECT * INTO u FROM auth.users WHERE id = auth.uid();
  IF u.id IS NULL THEN RETURN; END IF;

  SELECT id INTO v_id FROM empresas_portal WHERE auth_uid = u.id;

  IF v_id IS NULL AND u.email_confirmed_at IS NOT NULL THEN
    UPDATE empresas_portal SET auth_uid = u.id
    WHERE auth_uid IS NULL AND lower(email) = lower(u.email)
    RETURNING id INTO v_id;
  END IF;

  IF v_id IS NULL AND u.raw_user_meta_data->>'tipo' = 'empresa' THEN
    INSERT INTO empresas_portal (auth_uid, email, nombre_empresa, contacto_nombre, telefono, sector)
    VALUES (
      u.id, u.email,
      coalesce(nullif(u.raw_user_meta_data->>'nombre_empresa', ''), u.email),
      coalesce(nullif(u.raw_user_meta_data->>'contacto_nombre', ''), u.email),
      nullif(u.raw_user_meta_data->>'telefono', ''),
      nullif(u.raw_user_meta_data->>'sector', '')
    )
    RETURNING id INTO v_id;
  END IF;

  RETURN QUERY SELECT * FROM empresas_portal WHERE id = v_id;
END $$;

-- 4. Lo mismo para el perfil de candidata
CREATE OR REPLACE FUNCTION public.mi_perfil_candidata()
RETURNS SETOF public.perfiles_candidato
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  u auth.users;
  v_id uuid;
BEGIN
  SELECT * INTO u FROM auth.users WHERE id = auth.uid();
  IF u.id IS NULL THEN RETURN; END IF;

  SELECT id INTO v_id FROM perfiles_candidato WHERE auth_uid = u.id;

  IF v_id IS NULL AND u.email_confirmed_at IS NOT NULL THEN
    UPDATE perfiles_candidato SET auth_uid = u.id
    WHERE auth_uid IS NULL AND lower(email) = lower(u.email)
    RETURNING id INTO v_id;
  END IF;

  IF v_id IS NULL AND u.raw_user_meta_data->>'tipo' = 'candidata' THEN
    INSERT INTO perfiles_candidato (auth_uid, email, nombre, apellido)
    VALUES (
      u.id, u.email,
      coalesce(nullif(u.raw_user_meta_data->>'nombre', ''), split_part(u.email, '@', 1)),
      nullif(u.raw_user_meta_data->>'apellido', '')
    )
    RETURNING id INTO v_id;
  END IF;

  RETURN QUERY SELECT * FROM perfiles_candidato WHERE id = v_id;
END $$;

REVOKE EXECUTE ON FUNCTION public.mi_empresa_portal() FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.mi_perfil_candidata() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mi_empresa_portal() TO authenticated;
GRANT EXECUTE ON FUNCTION public.mi_perfil_candidata() TO authenticated;

-- 5. Reglas de acceso. Las reglas "Admin total ..." quedan como están
--    (después de seguridad-1 solo aplican a admins).

-- Empresas: el nombre se sigue viendo en las vacantes; cada empresa edita solo la suya.
--           Ya no se crean desde el navegador (lo hace mi_empresa_portal).
DROP POLICY IF EXISTS "Registro público empresas" ON public.empresas_portal;
DROP POLICY IF EXISTS "Empresa edita su perfil" ON public.empresas_portal;
CREATE POLICY "Empresa edita su perfil" ON public.empresas_portal
  FOR UPDATE USING (auth_uid = auth.uid()) WITH CHECK (auth_uid = auth.uid());

-- Vacantes: el público ve solo las aprobadas; cada empresa ve y publica las suyas.
DROP POLICY IF EXISTS "Ver vacantes aprobadas" ON public.vacantes_portal;
DROP POLICY IF EXISTS "Empresas publican vacantes" ON public.vacantes_portal;
DROP POLICY IF EXISTS "Público ve vacantes aprobadas" ON public.vacantes_portal;
DROP POLICY IF EXISTS "Empresa ve sus vacantes" ON public.vacantes_portal;
DROP POLICY IF EXISTS "Empresa publica sus vacantes" ON public.vacantes_portal;
CREATE POLICY "Público ve vacantes aprobadas" ON public.vacantes_portal
  FOR SELECT USING (estado = 'aprobada');
CREATE POLICY "Empresa ve sus vacantes" ON public.vacantes_portal
  FOR SELECT USING (empresa_id IN (SELECT id FROM public.empresas_portal WHERE auth_uid = auth.uid()));
CREATE POLICY "Empresa publica sus vacantes" ON public.vacantes_portal
  FOR INSERT WITH CHECK (
    estado = 'pendiente'
    AND empresa_id IN (SELECT id FROM public.empresas_portal WHERE auth_uid = auth.uid())
  );

-- Aplicaciones: cualquiera aplica (se mantiene "Candidatos aplican");
--               solo la empresa dueña de la vacante las lee.
DROP POLICY IF EXISTS "Ver aplicaciones" ON public.aplicaciones_vacante;
DROP POLICY IF EXISTS "Empresa ve aplicaciones a sus vacantes" ON public.aplicaciones_vacante;
CREATE POLICY "Empresa ve aplicaciones a sus vacantes" ON public.aplicaciones_vacante
  FOR SELECT USING (vacante_id IN (
    SELECT v.id FROM public.vacantes_portal v
    JOIN public.empresas_portal e ON e.id = v.empresa_id
    WHERE e.auth_uid = auth.uid()
  ));

-- Perfiles de candidata: se ven los públicos; cada una ve y edita solo el suyo.
DROP POLICY IF EXISTS "Registro público perfiles" ON public.perfiles_candidato;
DROP POLICY IF EXISTS "Ver perfiles públicos" ON public.perfiles_candidato;
DROP POLICY IF EXISTS "Actualizar perfil propio" ON public.perfiles_candidato;
DROP POLICY IF EXISTS "Perfiles públicos visibles" ON public.perfiles_candidato;
DROP POLICY IF EXISTS "Candidata edita su perfil" ON public.perfiles_candidato;
CREATE POLICY "Perfiles públicos visibles" ON public.perfiles_candidato
  FOR SELECT USING (perfil_publico = true OR auth_uid = auth.uid());
CREATE POLICY "Candidata edita su perfil" ON public.perfiles_candidato
  FOR UPDATE USING (auth_uid = auth.uid()) WITH CHECK (auth_uid = auth.uid());

-- Vínculo candidata ↔ posición al aplicar desde el portal (antes fallaba en silencio)
DROP POLICY IF EXISTS "Portal vincula candidata a posición" ON public.candidato_posicion;
CREATE POLICY "Portal vincula candidata a posición" ON public.candidato_posicion
  FOR INSERT WITH CHECK (estado = 'identificado');

-- 6. Comprobación: estas columnas ya NO deben aparecer (debe salir vacío)
SELECT table_name, column_name FROM information_schema.columns
WHERE table_schema = 'public' AND column_name = 'password'
  AND table_name IN ('empresas_portal', 'perfiles_candidato');
