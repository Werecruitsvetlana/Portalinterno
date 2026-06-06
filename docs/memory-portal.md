# Memory: Portal We Recruit DR

**Proyecto principal.** Portal de empleo en República Dominicana.
**URL:** https://www.werecruitdr.com
**Estado actual:** Activo y en operación.

---

## Qué es el portal

Portal de empleo especializado en talento dominicano. Conecta candidatos con empresas que buscan reclutamiento de calidad. Posicionamiento: "Human First" — evaluación de habilidades técnicas y blandas, no solo CV.

**Audiencias:**
- **Candidatos:** buscan vacantes activas, aplican directamente desde el portal.
- **Empresas:** contratan el servicio de reclutamiento/headhunting de Svetlana.

---

## Estado del portal (observado el 2026-06-05)

**Métricas visibles en el sitio:**
- 180+ vacantes activas
- 5,200+ empresas aliadas
- Colocaciones exitosas (sin número visible)

**Secciones del sitio:**
- Vacantes (listado con filtros por modalidad, sector, salario y experiencia)
- Quiénes somos
- Para empresas
- Servicios
- Publicar vacante

**Servicios que ofrece:**
1. Reclutamiento especializado
2. Headhunting ejecutivo
3. Evaluación de fit cultural

**Datos de contacto del portal:**
- Email: svetlana@werecruitdr.com
- WhatsApp: +1 (849) 350-5577

**Formulario de aplicación de candidatos captura:**
Nombre, apellido, email, teléfono, ciudad, LinkedIn, años de experiencia, salario esperado (DOP), pitch del candidato, CV (PDF o Word).

---

## Tecnología

| Herramienta | Función |
|---|---|
| Netlify | Hosting y despliegue del portal |
| Airtable | Base de datos — vacantes, candidatos y empresas |

### Estructura Airtable — Base: "We Recruit DR" (`appswELS9FJd6iGEM`)

**Tabla: Candidatos** (`tblPGc1HFXlXgmXIb`)
Registra todos los candidatos que aplican desde el portal.
Campos: Nombre, Apellido, Email, Teléfono, LinkedIn, Vacante aplicada, Estado, Años de experiencia, Salario esperado (DOP), Carta de motivación, Notas internas, Fecha de aplicación, CV (adjunto), Nombre del candidato (AI).

**Tabla: Vacantes** (`tbluuQ3gnvKBxqobF`)
Todas las vacantes publicadas en el portal.
Campos: Título del puesto, Empresa, Sector, Tipo (presencial/remoto/etc.), Salario mínimo y máximo (DOP), Ubicación, Descripción, Requisitos, Estado, Fecha de publicación.

**Tabla: Empresas** (`tbleoyC1KsRuO0Tvf`)
Empresas clientes de We Recruit DR.
Campos: Empresa, Contacto, Email, Teléfono, Sector, Sitio web, Notas, Estado.

---

## Portal interno de gestión

Además del portal público, se está construyendo un portal interno para que Svetlana gestione su operación: candidatos, posiciones, empresas, ternas, cotizaciones, facturas y cobros. Hoy todo eso vive en su cabeza y correo.

**Arquitectura:** HTML autocontenido + Supabase + Vercel + Vanilla JS
**Spec completo:** `docs/especificacion-portal.md`

**Supabase:**
- Proyecto: `bohkpbkktcnwsglvcrax`
- URL: `https://bohkpbkktcnwsglvcrax.supabase.co`
- Conectado vía GitHub

**Estructura del proyecto:**
```
DB/            ← Scripts SQL ejecutados en Supabase
pages/         ← Archivos HTML del portal (uno por módulo)
docs/          ← Especificación, memory, documentación
referencias/   ← Archivos de referencia
```

---

## Estado de desarrollo

### Fase 1 — Completada (2026-06-06)
- ✅ Base de datos creada en Supabase (9 tablas, RLS, storage bucket)
- ✅ `pages/login.html` — Crear cuenta e iniciar sesión
- ✅ `pages/index.html` — Dashboard con KPIs y resumen
- ✅ `pages/candidatos.html` — CRUD con foto, CV, evaluación por criterios, estrellas
- ✅ `pages/posiciones.html` — CRUD con estados, vinculación a empresas, asignación de candidatos
- ✅ `pages/empresas.html` — CRUD con stats de posiciones
- ⏳ Pendiente: desplegar en Vercel y probar en vivo

### Fase 2 — Pendiente
- Ternas con generación de PDF
- Dashboard por empresa

### Fase 3 — Pendiente
- Cotizaciones con generación de PDF
- Facturación con aging
- Reportes y métricas

### Fase 4 — Pendiente
- Herramienta de evaluación psicométrica propia (cuestionario por link)

### Fase 5 — Pendiente
- Roles y usuarios adicionales

---

## Próximos pasos

1. Desplegar en Vercel y probar login + CRUD
2. Crear cuenta de usuario (Svetlana) en el portal
3. Cargar datos iniciales (empresas, candidatos)
4. Construir Fase 2: Ternas con PDF

---

## Decisiones y cambios

### 2026-06-06 — Fase 1 construida
Creadas las 5 páginas HTML de Fase 1 + migración SQL ejecutada en Supabase. Se incluyó empresas.html (no estaba en el plan original de Fase 1) porque posiciones depende de tener empresas registradas. Proyecto reorganizado en carpetas: DB/, pages/, docs/, referencias/.

### 2026-06-06 — Discovery del portal interno completado
Entrevista guiada completada. Definidos: 9 módulos, 10 tablas en DB, flujos de estado para candidatos/posiciones/cotizaciones/facturas, generación de PDFs (terna, cotización, factura), métricas y reportes. Decisiones clave: un solo tipo de servicio, terna de 3, portal genera PDFs, evaluación por 5 criterios + promedio, herramienta psicométrica propia en fase 4 (cuestionario que llena el candidato por link). Sin notas de crédito ni descuentos. Solo RD$.

### 2026-06-05 — Proyecto creado
Se revisó el portal público y se documentó su estado actual. Proyecto designado como el más importante de We Recruit.
