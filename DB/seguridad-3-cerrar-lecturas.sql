-- =============================================
-- SEGURIDAD 3 — Cerrar lecturas públicas + banca de We Recruit Women
-- Ejecutar en: Supabase → SQL Editor → New query → Run
-- Requiere haber corrido seguridad-1 y seguridad-2.
--
-- Problema: en candidatos, aplicaciones_vacante y vacantes_portal había reglas
-- creadas a mano (ej. "Anon puede leer aplicaciones") que dejaban leer datos
-- personales a cualquier visitante.
--
-- Este script, en las tablas de abajo, BORRA toda regla que no sea de admin
-- (es_admin) ni esté en la lista de reglas necesarias, y deja solo:
--   - candidatos: el portal puede INSERTAR (aplicar), nadie lee salvo admins.
--   - aplicaciones_vacante: cualquiera aplica; solo la empresa dueña lee.
--   - vacantes_portal: público ve aprobadas; la empresa ve y publica las suyas.
--   - candidato_posicion: el portal crea el vínculo al aplicar.
--   - empresas_portal / perfiles_candidato: las reglas de seguridad-2.
--   - banca_candidatos: NUEVO, el formulario We Recruit Women puede INSERTAR
--     (nunca leer). El CV va a banca-cvs/women/ (bucket privado).
-- No borra datos. Al final muestra qué reglas quitó y cuáles quedaron.
-- =============================================

CREATE TEMP TABLE IF NOT EXISTS _reglas_quitadas (tabla text, regla text, cmd text, usando text);
TRUNCATE _reglas_quitadas;

DO $$
DECLARE
  r record;
  necesarias text[] := ARRAY[
    'Portal público puede insertar candidatos',
    'Candidatos aplican',
    'Empresa ve aplicaciones a sus vacantes',
    'Público ve vacantes aprobadas',
    'Empresa ve sus vacantes',
    'Empresa publica sus vacantes',
    'Portal vincula candidata a posición',
    'Lectura pública empresas',
    'Empresa edita su perfil',
    'Perfiles públicos visibles',
    'Candidata edita su perfil',
    'Women: banca recibe candidatas'
  ];
BEGIN
  FOR r IN
    SELECT * FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('candidatos', 'aplicaciones_vacante', 'vacantes_portal', 'candidato_posicion',
                        'empresas_portal', 'perfiles_candidato', 'banca_candidatos')
      AND coalesce(qual, '') NOT ILIKE '%es_admin%'
      AND coalesce(with_check, '') NOT ILIKE '%es_admin%'
      AND policyname <> ALL (necesarias)
  LOOP
    INSERT INTO _reglas_quitadas VALUES (r.tablename, r.policyname, r.cmd, coalesce(r.qual, r.with_check));
    EXECUTE format('DROP POLICY %I ON public.%I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- Reglas necesarias (se crean si faltan)
DROP POLICY IF EXISTS "Portal público puede insertar candidatos" ON public.candidatos;
CREATE POLICY "Portal público puede insertar candidatos" ON public.candidatos
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Candidatos aplican" ON public.aplicaciones_vacante;
CREATE POLICY "Candidatos aplican" ON public.aplicaciones_vacante
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Lectura pública empresas" ON public.empresas_portal;
CREATE POLICY "Lectura pública empresas" ON public.empresas_portal
  FOR SELECT USING (true);

-- Banca: el formulario We Recruit Women solo puede insertar filas suyas
DROP POLICY IF EXISTS "Women: banca recibe candidatas" ON public.banca_candidatos;
CREATE POLICY "Women: banca recibe candidatas" ON public.banca_candidatos
  FOR INSERT WITH CHECK (
    id LIKE 'ww-%'
    AND posicion = 'We Recruit Women'
    AND tipo = 'We Recruit Women'
    AND coalesce(estado, 'nuevo') = 'nuevo'
  );

-- CV de la banca: solo subir (no leer) dentro de banca-cvs/women/
DROP POLICY IF EXISTS "Women: subir CV a la banca" ON storage.objects;
CREATE POLICY "Women: subir CV a la banca" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'banca-cvs' AND name LIKE 'women/ww-%');

-- Resultado: qué se quitó y qué quedó
SELECT 'QUITADA' AS estado, tabla, regla, cmd, usando FROM _reglas_quitadas
UNION ALL
SELECT 'queda', tablename, policyname, cmd, coalesce(qual, with_check)
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('candidatos', 'aplicaciones_vacante', 'vacantes_portal', 'candidato_posicion',
                    'empresas_portal', 'perfiles_candidato', 'banca_candidatos')
ORDER BY 1, 2, 3;
