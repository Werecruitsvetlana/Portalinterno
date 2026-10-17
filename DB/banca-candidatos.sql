-- =============================================
-- BANCA DE CANDIDATOS (CVs recibidos por correo)
-- Ejecutar una sola vez en: Supabase > SQL Editor
-- =============================================

CREATE TABLE IF NOT EXISTS public.banca_candidatos (
  id text PRIMARY KEY,
  nombre text NOT NULL,
  posicion text,
  nivel text,
  pais text,
  telefono text,
  email text,
  fecha_correo date,
  asunto text,
  tipo text,
  cv_path text,
  cv_nombre text,
  cv_ok boolean DEFAULT false,
  estado text DEFAULT 'nuevo',
  notas text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_banca_posicion ON public.banca_candidatos(posicion);
CREATE INDEX IF NOT EXISTS idx_banca_pais ON public.banca_candidatos(pais);

ALTER TABLE public.banca_candidatos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Acceso total autenticados" ON public.banca_candidatos;
CREATE POLICY "Acceso total autenticados" ON public.banca_candidatos
  FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- Bucket PRIVADO para los CVs de la banca (solo usuarios con sesión pueden abrirlos)
INSERT INTO storage.buckets (id, name, public) VALUES ('banca-cvs', 'banca-cvs', false)
  ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Banca: leer autenticados" ON storage.objects;
CREATE POLICY "Banca: leer autenticados" ON storage.objects
  FOR SELECT USING (bucket_id = 'banca-cvs' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Banca: subir autenticados" ON storage.objects;
CREATE POLICY "Banca: subir autenticados" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'banca-cvs' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Banca: actualizar autenticados" ON storage.objects;
CREATE POLICY "Banca: actualizar autenticados" ON storage.objects
  FOR UPDATE USING (bucket_id = 'banca-cvs' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Banca: borrar autenticados" ON storage.objects;
CREATE POLICY "Banca: borrar autenticados" ON storage.objects
  FOR DELETE USING (bucket_id = 'banca-cvs' AND auth.role() = 'authenticated');

-- 2026-10-01: columnas para búsqueda dentro del CV y filtro de ciudad (ya ejecutado)
ALTER TABLE public.banca_candidatos ADD COLUMN IF NOT EXISTS ciudad text;
ALTER TABLE public.banca_candidatos ADD COLUMN IF NOT EXISTS texto text;
CREATE INDEX IF NOT EXISTS idx_banca_ciudad ON public.banca_candidatos(ciudad);
