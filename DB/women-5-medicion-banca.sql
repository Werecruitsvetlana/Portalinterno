-- =============================================
-- WOMEN 5 — Preguntas de medición en la banca de candidatos
-- Ejecutar en: Supabase → SQL Editor → New query → Run
-- Solo agrega columnas (no borra nada). Es seguro correrlo más de una vez.
--
-- Las llenan el formulario "Únete a la banca" (#unete) y el CV Builder,
-- solo si la candidata responde y acepta. Sirven para el informe de impacto
-- de We Recruit Women (MIT Solve, Cartier, etc.).
-- =============================================

ALTER TABLE public.banca_candidatos
  ADD COLUMN IF NOT EXISTS sexo text,
  ADD COLUMN IF NOT EXISTS salario_anterior_dop numeric,
  ADD COLUMN IF NOT EXISTS regresa_pausa_cuidado boolean,
  ADD COLUMN IF NOT EXISTS consentimiento_datos_ww boolean DEFAULT false;

-- Comprobación: deben salir 4 filas
SELECT column_name FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'banca_candidatos'
  AND column_name IN ('sexo', 'salario_anterior_dop', 'regresa_pausa_cuidado', 'consentimiento_datos_ww');

-- Consulta de impacto (para cuando haya datos):
-- SELECT sexo, count(*) AS candidatas,
--        round(avg(salario_anterior_dop)) AS salario_anterior_promedio,
--        count(*) FILTER (WHERE regresa_pausa_cuidado) AS regresan_tras_pausa
-- FROM public.banca_candidatos
-- WHERE consentimiento_datos_ww = true
-- GROUP BY sexo;
