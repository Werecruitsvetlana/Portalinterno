-- =============================================
-- ALTER TABLE: Columnas del portal público
-- Ejecutar en: Supabase > SQL Editor
-- =============================================

ALTER TABLE public.candidatos
  ADD COLUMN IF NOT EXISTS apellido          text,
  ADD COLUMN IF NOT EXISTS linkedin          text,
  ADD COLUMN IF NOT EXISTS ciudad            text,
  ADD COLUMN IF NOT EXISTS anos_experiencia  text,
  ADD COLUMN IF NOT EXISTS salario_esperado_dop text,
  ADD COLUMN IF NOT EXISTS fuente            text;
