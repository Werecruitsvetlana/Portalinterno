# Prompt para Claude Code — Portal We Recruit DR

Copia y pega esto en Claude Code para continuar el desarrollo.

---

## PROMPT:

Estoy construyendo un portal interno de gestión para mi empresa de reclutamiento, We Recruit DR. Necesito que me ayudes a conectar todo y continuar el desarrollo. Aquí tienes el contexto completo.

### Qué es el proyecto
Portal web interno para gestionar: candidatos, posiciones abiertas, empresas-cliente, ternas, cotizaciones, facturas y cobros. Lo uso solo yo (Svetlana Elias), pero la estructura queda preparada para agregar usuarios.

### Stack técnico
- **Frontend:** HTML autocontenido (un .html por módulo, CSS y JS inline, sin frameworks)
- **Backend/DB:** Supabase (PostgreSQL + Auth + Storage)
- **Hosting:** Vercel
- **Repo:** GitHub (necesita conectarse)

### Credenciales de Supabase
- **Proyecto:** bohkpbkktcnwsglvcrax
- **URL:** https://bohkpbkktcnwsglvcrax.supabase.co
- **Anon Key:** eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJvaGtwYmtrdGNud3NnbHZjcmF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3NjY0MjYsImV4cCI6MjA5NjM0MjQyNn0.yW7atZCGHqipQ-KE-UH5J3DPlXvud5lzf5LMs3J9YzA
- **GitHub:** ya conectado al proyecto de Supabase

### Paleta de marca
- Azul oscuro: #063958
- Azul medio: #0F6B9F
- Verde menta: #CEE4CC

### Estructura del repo
```
DB/                 ← Scripts SQL ejecutados en Supabase
  migracion-fase1.sql
pages/              ← Archivos HTML del portal
  login.html
  index.html        ← Dashboard con KPIs, gráficos, aging
  candidatos.html   ← CRUD con foto, CV, evaluación, estrellas
  posiciones.html   ← CRUD con estados, asignación de candidatos
  empresas.html     ← CRUD con stats
docs/               ← Especificación y documentación
  especificacion-portal.md  ← Spec completo (módulos, DB, flujos)
  memory-portal.md          ← Estado del proyecto
referencias/        ← Archivos de referencia
```

### Base de datos (ya creada en Supabase)
9 tablas: empresas, posiciones, candidatos, evaluaciones_candidato, candidato_posicion, ternas, terna_candidatos, cotizaciones, facturas. RLS habilitado con política de acceso para usuarios autenticados. Storage bucket "archivos" para fotos y CVs.

### Estado actual — Fase 1 completada
- ✅ Login con Supabase Auth (email/password)
- ✅ Dashboard con 6 KPIs, gráficos de posiciones y facturación por mes, facturas con aging, top clientes
- ✅ CRUD de candidatos (foto, CV, evaluación por 5 criterios, estrellas, DISC)
- ✅ CRUD de posiciones (estados, vinculación a empresa, asignación de candidatos con cambio de estado)
- ✅ CRUD de empresas (con stats de posiciones)

### Lo que necesito ahora

1. **Crear repo en GitHub** y subir todos los archivos
2. **Conectar con Vercel** para deploy automático desde GitHub
3. **Continuar con Fase 2:**
   - Ternas: seleccionar 3 candidatos por posición y generar PDF con plantilla de marca
   - Dashboard por empresa (al entrar a una empresa ver sus posiciones, candidatos enviados, facturas)
4. **Fase 3:**
   - Cotizaciones con generación de PDF (desglose: puesto, salario, fee = 1 mes de salario)
   - Facturación con aging y reporte mensual
   - Reportes: tasa de colocación, tiempo promedio de llenado, ingresos por mes y por cliente

### Notas técnicas importantes
- El cliente de Supabase se llama `sb` (no `supabase`) para evitar conflicto con `window.supabase` del CDN
- Cada HTML es autocontenido: no hay archivos CSS o JS separados
- Moneda: solo pesos dominicanos (RD$)
- Los PDFs generados deben usar la paleta de marca de We Recruit
- La variable `SUPABASE_URL` y `SUPABASE_KEY` están hardcodeadas en cada HTML (para producción considerar variables de entorno)

### Flujos de estado
- **Candidato por posición:** Identificado → Enviado → En entrevista → Aprobado → Contratado / Rechazado → Disponible
- **Posición:** Abierta → En proceso → Cubierta / Cancelada
- **Cotización:** Borrador → Enviada → Aceptada / Rechazada
- **Factura:** Enviada → Pendiente → Cobrada / Vencida

### Quién soy
Svetlana Elias, fundadora de We Recruit DR. Consultora de reclutamiento independiente en República Dominicana. Trabajo sola, manejo ~8 empresas-cliente y ~20 candidatos por mes. Mi fee es un mes de salario por colocación exitosa.
