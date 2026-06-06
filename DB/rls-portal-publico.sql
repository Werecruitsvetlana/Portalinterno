-- =============================================
-- RLS: Acceso anónimo desde el portal público
-- Ejecutar en: Supabase > SQL Editor
-- =============================================

-- 1. Permite que el portal público inserte candidatos sin autenticación.
--    Solo INSERT — lectura y modificación siguen requiriendo autenticación.
CREATE POLICY "Portal público puede insertar candidatos"
  ON public.candidatos
  FOR INSERT
  WITH CHECK (true);

-- 2. Permite que el portal público suba archivos al bucket "archivos",
--    exclusivamente dentro de la carpeta cvs/.
CREATE POLICY "Portal público puede subir CVs"
  ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'archivos' AND name LIKE 'cvs/%');
