-- =============================================
-- PORTAL WE RECRUIT DR — Migración Fase 1
-- Fecha: 2026-06-06
-- =============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- TABLA: empresas
-- =============================================
CREATE TABLE public.empresas (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  nombre text NOT NULL,
  contacto_nombre text,
  contacto_telefono text,
  contacto_email text,
  industria text,
  rnc text,
  direccion text,
  documento_acuerdo_url text,
  notas text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =============================================
-- TABLA: posiciones
-- =============================================
CREATE TABLE public.posiciones (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  empresa_id uuid REFERENCES public.empresas(id) ON DELETE SET NULL,
  titulo text NOT NULL,
  departamento text,
  salario_ofrecido numeric,
  ubicacion text,
  requisitos text,
  fecha_apertura date DEFAULT CURRENT_DATE,
  fecha_limite date,
  estado text DEFAULT 'abierta' CHECK (estado IN ('abierta', 'en_proceso', 'cubierta', 'cancelada')),
  notas text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =============================================
-- TABLA: candidatos
-- =============================================
CREATE TABLE public.candidatos (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  nombre text NOT NULL,
  telefono text,
  email text,
  carrera text,
  salario_esperado numeric,
  foto_url text,
  cv_url text,
  puntuacion_estrellas integer CHECK (puntuacion_estrellas BETWEEN 1 AND 5),
  resultado_disc text,
  notas text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- =============================================
-- TABLA: evaluaciones_candidato
-- =============================================
CREATE TABLE public.evaluaciones_candidato (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  candidato_id uuid REFERENCES public.candidatos(id) ON DELETE CASCADE,
  experiencia integer CHECK (experiencia BETWEEN 1 AND 5),
  actitud integer CHECK (actitud BETWEEN 1 AND 5),
  presentacion integer CHECK (presentacion BETWEEN 1 AND 5),
  referencias integer CHECK (referencias BETWEEN 1 AND 5),
  comunicacion integer CHECK (comunicacion BETWEEN 1 AND 5),
  promedio numeric GENERATED ALWAYS AS (
    (COALESCE(experiencia,0) + COALESCE(actitud,0) + COALESCE(presentacion,0) + COALESCE(referencias,0) + COALESCE(comunicacion,0))::numeric /
    NULLIF(
      (CASE WHEN experiencia IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN actitud IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN presentacion IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN referencias IS NOT NULL THEN 1 ELSE 0 END +
       CASE WHEN comunicacion IS NOT NULL THEN 1 ELSE 0 END), 0)
  ) STORED,
  evaluado_por uuid,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- TABLA: candidato_posicion
-- =============================================
CREATE TABLE public.candidato_posicion (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  candidato_id uuid REFERENCES public.candidatos(id) ON DELETE CASCADE,
  posicion_id uuid REFERENCES public.posiciones(id) ON DELETE CASCADE,
  estado text DEFAULT 'identificado' CHECK (estado IN ('identificado', 'enviado', 'en_entrevista', 'aprobado', 'contratado', 'rechazado', 'disponible')),
  feedback_cliente text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(candidato_id, posicion_id)
);

-- =============================================
-- TABLA: ternas
-- =============================================
CREATE TABLE public.ternas (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  posicion_id uuid REFERENCES public.posiciones(id) ON DELETE CASCADE,
  nombre text,
  fecha_envio date,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- TABLA: terna_candidatos
-- =============================================
CREATE TABLE public.terna_candidatos (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  terna_id uuid REFERENCES public.ternas(id) ON DELETE CASCADE,
  candidato_id uuid REFERENCES public.candidatos(id) ON DELETE CASCADE,
  orden integer CHECK (orden BETWEEN 1 AND 5)
);

-- =============================================
-- TABLA: cotizaciones
-- =============================================
CREATE TABLE public.cotizaciones (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  empresa_id uuid REFERENCES public.empresas(id) ON DELETE SET NULL,
  posicion_id uuid REFERENCES public.posiciones(id) ON DELETE SET NULL,
  numero text,
  titulo_puesto text,
  salario_mensual numeric,
  fee numeric,
  total numeric,
  estado text DEFAULT 'borrador' CHECK (estado IN ('borrador', 'enviada', 'aceptada', 'rechazada')),
  fecha_emision date DEFAULT CURRENT_DATE,
  notas text,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- TABLA: facturas
-- =============================================
CREATE TABLE public.facturas (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  empresa_id uuid REFERENCES public.empresas(id) ON DELETE SET NULL,
  cotizacion_id uuid REFERENCES public.cotizaciones(id) ON DELETE SET NULL,
  numero text,
  monto numeric,
  fecha_emision date DEFAULT CURRENT_DATE,
  fecha_vencimiento date,
  fecha_cobro date,
  estado text DEFAULT 'enviada' CHECK (estado IN ('enviada', 'pendiente', 'cobrada', 'vencida')),
  notas text,
  created_at timestamptz DEFAULT now()
);

-- =============================================
-- FUNCIÓN: actualizar updated_at automáticamente
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.empresas
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.posiciones
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidatos
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.candidato_posicion
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =============================================
-- RLS: Row Level Security
-- Fase 1: permite todo a usuarios autenticados
-- =============================================
ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posiciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidatos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evaluaciones_candidato ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidato_posicion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ternas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.terna_candidatos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cotizaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.facturas ENABLE ROW LEVEL SECURITY;

-- Políticas: acceso total para usuarios autenticados
CREATE POLICY "Acceso total autenticados" ON public.empresas FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.posiciones FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.candidatos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.evaluaciones_candidato FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.candidato_posicion FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.ternas FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.terna_candidatos FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.cotizaciones FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Acceso total autenticados" ON public.facturas FOR ALL USING (auth.role() = 'authenticated');

-- =============================================
-- STORAGE: Bucket para archivos (CVs y fotos)
-- =============================================
INSERT INTO storage.buckets (id, name, public) VALUES ('archivos', 'archivos', true);

-- Política de storage: usuarios autenticados pueden subir y leer
CREATE POLICY "Usuarios pueden subir archivos" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'archivos' AND auth.role() = 'authenticated');

CREATE POLICY "Archivos son públicos para leer" ON storage.objects
  FOR SELECT USING (bucket_id = 'archivos');

CREATE POLICY "Usuarios pueden actualizar sus archivos" ON storage.objects
  FOR UPDATE USING (bucket_id = 'archivos' AND auth.role() = 'authenticated');

CREATE POLICY "Usuarios pueden borrar sus archivos" ON storage.objects
  FOR DELETE USING (bucket_id = 'archivos' AND auth.role() = 'authenticated');
