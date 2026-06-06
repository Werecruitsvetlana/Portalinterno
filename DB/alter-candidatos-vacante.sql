-- =============================================
-- ALTER TABLE: Columna vacante aplicada
-- Ejecutar en: Supabase > SQL Editor
-- =============================================

ALTER TABLE public.candidatos
  ADD COLUMN IF NOT EXISTS vacante_aplicada text;
