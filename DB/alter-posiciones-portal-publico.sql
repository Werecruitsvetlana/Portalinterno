-- =============================================
-- Conexión portal público ↔ portal interno
-- Ejecutar en: Supabase > SQL Editor
-- =============================================

-- 1. Campos nuevos en posiciones (para mostrar en portal público)
ALTER TABLE public.posiciones
  ADD COLUMN IF NOT EXISTS tipo   text DEFAULT 'Presencial',
  ADD COLUMN IF NOT EXISTS sector text;

-- 2. Vincular candidatos con posiciones de Supabase
ALTER TABLE public.candidatos
  ADD COLUMN IF NOT EXISTS posicion_id uuid REFERENCES public.posiciones(id) ON DELETE SET NULL;

-- 3. El portal público (anon) puede leer posiciones activas
CREATE POLICY "Portal público ve posiciones abiertas"
  ON public.posiciones
  FOR SELECT
  USING (estado = 'abierta');

-- 4. El portal público (anon) puede leer nombres de empresas
CREATE POLICY "Portal público ve empresas"
  ON public.empresas
  FOR SELECT
  USING (true);
