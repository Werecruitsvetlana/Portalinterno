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
- ✅ Desplegado en Vercel (`portal-werecruitdr.vercel.app`)
- ✅ Vercel CLI instalado y conectado (`vercel --prod` para desplegar)
- ✅ GitHub repo: `Werecruitsvetlana/Portalinterno` (rama `master`)
- ⚠️ Bug pendiente: posiciones no cargan por caché del navegador (Ctrl+Shift+R para forzar)

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

1. Verificar que posiciones carga bien tras hard refresh (Ctrl+Shift+R)
2. Construir Fase 2: Ternas con PDF + Dashboard por empresa
3. Fase 3: Cotizaciones, Facturación, Reportes

---

## Decisiones y cambios

### 2026-06-06 — Fase 1 construida
Creadas las 5 páginas HTML de Fase 1 + migración SQL ejecutada en Supabase. Se incluyó empresas.html (no estaba en el plan original de Fase 1) porque posiciones depende de tener empresas registradas. Proyecto reorganizado en carpetas: DB/, pages/, docs/, referencias/.

### 2026-06-06 — Discovery del portal interno completado
Entrevista guiada completada. Definidos: 9 módulos, 10 tablas en DB, flujos de estado para candidatos/posiciones/cotizaciones/facturas, generación de PDFs (terna, cotización, factura), métricas y reportes. Decisiones clave: un solo tipo de servicio, terna de 3, portal genera PDFs, evaluación por 5 criterios + promedio, herramienta psicométrica propia en fase 4 (cuestionario que llena el candidato por link). Sin notas de crédito ni descuentos. Solo RD$.

### 2026-07-27 — Infraestructura conectada
GitHub CLI + Vercel CLI instalados. Repo conectado, deploy automático con `vercel --prod`. Usuarios Supabase creados: Felix Rosa (frosa@accountone.do), Daniel Jaar (talent@werecruitdr.com). Bug de posiciones diagnosticado: la consulta a Supabase funciona (probado vía JS), el problema era caché del navegador sirviendo versión vieja con `supabase.from` en vez de `sb.from`.

### 2026-06-05 — Proyecto creado
Se revisó el portal público y se documentó su estado actual. Proyecto designado como el más importante de We Recruit.

### 2026-10-01 — Pestaña "Banca de Candidatos" (construida, pendiente de activar)
Nueva página `banca.html` (también en `pages/`) con enlace en el menú de todas las páginas. Muestra los CVs recibidos por correo (talent@), organizados por posición: buscador, filtros por posición / país (RD por defecto) / nivel / estado, estado y notas editables, y "Ver CV" con enlace firmado.
- Tabla nueva `banca_candidatos` y bucket PRIVADO `banca-cvs`: script en `DB/banca-candidatos.sql` (**pendiente de ejecutar en Supabase SQL Editor**).
- Datos: 3,783 CVs únicos (~2.2 GB) en `CV-s talent\Banca por Posicion\` (38 carpetas por posición + `Banca de Candidatos.xlsx` + `banca_import.json`). Extraídos del buzón con Thunderbird (IMAP imap.secureserver.net) y scripts en `CV-s talent\_Entrada correo\`.
- Carga: botón "Importar carpeta de CVs" en la pestaña → elegir la carpeta `Banca por Posicion`. Crea las filas y sube los archivos; se puede reanudar.
- Requiere Supabase Pro (el plan gratuito da 1 GB de almacenamiento). Svetlana decidió pasar a Pro.
- **Pendiente:** (1) pasar a Pro, (2) ejecutar el SQL, (3) `vercel --prod`, (4) importar la carpeta desde el portal.
- Nota: quedó `.git/_stale_index_lock_borrar` (archivo vacío, se puede borrar) y ya existía `.git/HEAD.lock` del 7-sep que puede bloquear commits.

### 2026-10-01 (tarde) — Banca de Candidatos activa y rediseñada
- Activada: Supabase en Pro, SQL ejecutado, 3,783 filas y 3,783 archivos subidos al bucket privado `banca-cvs`.
- Rediseño (`banca.html` v2; la v1 quedó en `docs/banca-v1-respaldo.html`): entrada con carpetas por posición, buscador global que también busca dentro del texto del CV (columna `texto`, `ilike`), filtros de ciudad / nivel / estado / fecha, y panel lateral con vista previa del CV, WhatsApp, correo, estado y notas. **Pendiente: `vercel --prod` para publicar la v2.**
- Actualización diaria: skill `actualizar-banca-candidatos` + tarea programada 7:50 a.m.; procedimiento en `CV-s talent\_Entrada correo\PROCEDIMIENTO.md`.

### 2026-10-17 — Pestaña "Vacantes Abiertas" (construida, pendiente de desplegar)
Nueva página `vacantes-abiertas.html` (raíz y `pages/`), con enlace "⏱️ Vacantes Abiertas" en el menú de todas las páginas, debajo de Posiciones. Tracker de tiempo: lee `posiciones` con estado abierta/en proceso; "Recibida" = `fecha_apertura` (editable en la tabla), días abiertos calculados contra hoy con semáforo (0–14 / 15–30 / 31–60 / +60), fecha límite con días restantes o vencida, conteo de candidatos desde `candidato_posicion`, estado editable (cubierta/cancelada la saca de la lista). KPIs: total, promedio de días, la más antigua, cuántas pasan de 30 días. Botón "+ Nueva vacante" crea la fila en `posiciones`. No requiere SQL nuevo.
Pendiente posible: columna `fecha_cierre` para medir tiempo de cierre de las vacantes cubiertas.
