-- =============================================
-- NOTAS DEL DASHBOARD — Centro de notas personal
-- Ejecutar en Supabase SQL Editor
-- =============================================

CREATE TABLE public.notas (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  titulo text NOT NULL DEFAULT 'Sin título',
  contenido text,
  color text DEFAULT 'yellow' CHECK (color IN ('yellow', 'blue', 'green', 'pink', 'gray')),
  fijada boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Trigger para updated_at
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.notas
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- RLS
ALTER TABLE public.notas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Acceso total autenticados" ON public.notas FOR ALL USING (auth.role() = 'authenticated');
