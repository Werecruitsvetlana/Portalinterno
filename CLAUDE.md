# Proyecto: Portal We Recruit DR

## Qué es
Portal interno de gestión para We Recruit DR. Centraliza candidatos, posiciones, empresas-cliente, ternas, cotizaciones, facturas y cobros.

## Arquitectura
- HTML autocontenido (un .html por módulo, CSS y JS inline)
- Supabase (base de datos + auth)
- Vercel (deployment)
- Vanilla JS, sin frameworks
- Diseño visual con Claude Design

## Paleta de marca
- Azul oscuro: #063958
- Azul medio: #0F6B9F
- Verde menta: #CEE4CC

## Estructura de carpetas

```
DB/            ← Scripts SQL que se corren en Supabase
pages/         ← Archivos HTML del portal (uno por módulo)
docs/          ← Especificación, memory y documentación del proyecto
referencias/   ← Archivos de referencia (PDFs, cotizaciones, diseños)
```

## Archivos clave
- `docs/especificacion-portal.md` — Spec completo (módulos, DB, flujos, prioridad)
- `docs/memory-portal.md` — Estado del proyecto y decisiones
- `DB/migracion-fase1.sql` — Migración inicial de base de datos

## Reglas
- Consulta `especificacion-portal.md` antes de construir cualquier módulo
- Sigue la prioridad de desarrollo definida (Fase 1 primero)
- Los PDFs generados usan la plantilla de marca de We Recruit
- Moneda: solo pesos dominicanos (RD$)
- Un solo usuario (admin) en fase 1. Estructura preparada para roles
