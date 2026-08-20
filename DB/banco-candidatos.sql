-- =============================================
-- BANCO DE CANDIDATOS — Nuevas columnas
-- Ejecutar en Supabase SQL Editor
-- =============================================

-- Agregar columna departamento/área
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS departamento text;

-- Agregar columna fuente (de dónde viene el candidato)
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS fuente text
  CHECK (fuente IN ('email', 'linkedin', 'referido', 'portal', 'otro'));

-- Agregar columna nivel
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS nivel text
  CHECK (nivel IN ('junior', 'mid', 'senior', 'gerencial'));

-- Agregar columna apellido si no existe
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS apellido text;

-- Agregar columna ciudad si no existe
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS ciudad text;

-- Agregar columna linkedin si no existe
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS linkedin text;

-- Agregar columna años de experiencia si no existe
ALTER TABLE public.candidatos ADD COLUMN IF NOT EXISTS anos_experiencia text;

-- Índice para búsquedas rápidas por departamento
CREATE INDEX IF NOT EXISTS idx_candidatos_departamento ON public.candidatos(departamento);

-- Índice para búsquedas por fuente
CREATE INDEX IF NOT EXISTS idx_candidatos_fuente ON public.candidatos(fuente);
