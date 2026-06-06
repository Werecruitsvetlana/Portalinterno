# Especificación: Portal We Recruit DR

**Fecha:** 6 de junio de 2026
**Para:** Svetlana Elias, We Recruit DR
**Versión:** 1.0 — Discovery completado

---

## 1. Resumen ejecutivo

Portal interno de gestión para We Recruit DR, una consultora de reclutamiento independiente operada por una sola persona. El objetivo: centralizar todo lo que hoy vive en la cabeza y el correo de Svetlana en un solo lugar — candidatos, posiciones abiertas, empresas-cliente, ternas, cotizaciones, facturas y cobros.

El portal resuelve tres dolores concretos: perder candidatos buenos que fueron rechazados en una posición pero sirven para otras, no tener visibilidad del estado de cada cliente, y no trackear posiciones abiertas ni cobros pendientes.

**Arquitectura técnica:**
- HTML autocontenido (un .html por módulo, CSS y JS inline)
- Supabase como base de datos y autenticación
- Vercel para deployment
- Vanilla JS, sin frameworks

**Usuario inicial:** Svetlana (admin/dueña). Estructura preparada para agregar usuarios con roles a futuro.

---

## 2. Módulos definidos

| # | Módulo | Descripción |
|---|---|---|
| 1 | **Dashboard** | Vista principal al abrir el portal. Posiciones abiertas, candidatos recientes, facturas pendientes con aging, resumen del mes |
| 2 | **Candidatos** | Base de datos de candidatos con foto, CV, puntuación, evaluación por criterios, resultado DISC, estados por posición |
| 3 | **Posiciones** | Puestos abiertos vinculados a empresas. Estados: Abierta → En proceso → Cubierta → Cancelada |
| 4 | **Empresas-cliente** | Perfil de cada empresa con contacto, datos fiscales, documentos de acuerdo, dashboard individual |
| 5 | **Ternas** | Selección de 3 candidatos por posición, generación de reporte PDF con la plantilla de marca We Recruit |
| 6 | **Cotizaciones** | Generación de cotizaciones en PDF con desglose (puesto, salario, fee) |
| 7 | **Facturación** | Tracking de facturas con estados y aging. Generación de factura PDF. Reporte mensual |
| 8 | **Reportes** | Tasa de colocación, tiempo promedio para llenar posición, ingresos por mes, ingresos por cliente |
| 9 | **Configuración** | Datos de la empresa, usuarios y roles (fase 2), parámetros generales |

---

## 3. Estructura de base de datos

### Tabla: `usuarios`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | Generado por Supabase Auth |
| email | text | Único |
| nombre | text | |
| rol | text | 'admin' por defecto. Preparado para: 'reclutador', 'viewer' |
| created_at | timestamptz | |

### Tabla: `empresas`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| nombre | text | NOT NULL |
| contacto_nombre | text | Persona de contacto principal |
| contacto_telefono | text | |
| contacto_email | text | |
| industria | text | Sector de la empresa |
| rnc | text | Para cotizaciones y facturas |
| direccion | text | |
| documento_acuerdo_url | text | Link al archivo del acuerdo/contrato |
| notas | text | Campo libre |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### Tabla: `posiciones`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| empresa_id | uuid (FK → empresas) | |
| titulo | text | NOT NULL |
| departamento | text | |
| salario_ofrecido | numeric | En RD$ |
| ubicacion | text | |
| requisitos | text | |
| fecha_apertura | date | |
| fecha_limite | date | |
| estado | text | 'abierta', 'en_proceso', 'cubierta', 'cancelada' |
| notas | text | |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### Tabla: `candidatos`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| nombre | text | NOT NULL |
| telefono | text | |
| email | text | |
| carrera | text | Carrera que estudió |
| salario_esperado | numeric | En RD$ |
| foto_url | text | Foto de perfil |
| cv_url | text | Archivo del CV (PDF) |
| puntuacion_estrellas | integer | 1-5, evaluación general de la reclutadora |
| resultado_disc | text | Resultado del análisis DISC (fase 1: texto libre) |
| notas | text | |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### Tabla: `evaluaciones_candidato`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| candidato_id | uuid (FK → candidatos) | |
| experiencia | integer | 1-5 |
| actitud | integer | 1-5 |
| presentacion | integer | 1-5 |
| referencias | integer | 1-5 |
| comunicacion | integer | 1-5 |
| promedio | numeric | Calculado: promedio de los 5 criterios |
| evaluado_por | uuid (FK → usuarios) | |
| created_at | timestamptz | |

### Tabla: `candidato_posicion`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| candidato_id | uuid (FK → candidatos) | |
| posicion_id | uuid (FK → posiciones) | |
| estado | text | 'identificado', 'enviado', 'en_entrevista', 'aprobado', 'contratado', 'rechazado', 'disponible' |
| feedback_cliente | text | Notas del feedback (opcional) |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### Tabla: `ternas`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| posicion_id | uuid (FK → posiciones) | |
| nombre | text | Nombre descriptivo de la terna |
| fecha_envio | date | |
| created_at | timestamptz | |

### Tabla: `terna_candidatos`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| terna_id | uuid (FK → ternas) | |
| candidato_id | uuid (FK → candidatos) | |
| orden | integer | Posición en la terna (1, 2, 3) |

### Tabla: `cotizaciones`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| empresa_id | uuid (FK → empresas) | |
| posicion_id | uuid (FK → posiciones) | Puede ser NULL si es cotización general |
| numero | text | Número secuencial de cotización |
| titulo_puesto | text | |
| salario_mensual | numeric | RD$ |
| fee | numeric | = salario_mensual |
| total | numeric | |
| estado | text | 'borrador', 'enviada', 'aceptada', 'rechazada' |
| fecha_emision | date | |
| notas | text | |
| created_at | timestamptz | |

### Tabla: `facturas`
| Columna | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| empresa_id | uuid (FK → empresas) | |
| cotizacion_id | uuid (FK → cotizaciones) | Puede ser NULL |
| numero | text | Número secuencial de factura |
| monto | numeric | RD$ |
| fecha_emision | date | |
| fecha_vencimiento | date | |
| fecha_cobro | date | NULL hasta que se cobre |
| estado | text | 'enviada', 'pendiente', 'cobrada', 'vencida' |
| dias_mora | integer | Calculado: días desde vencimiento sin cobro |
| notas | text | |
| created_at | timestamptz | |

---

## 4. Roles y permisos

| Acción | Admin | Reclutador (futuro) | Viewer (futuro) |
|---|---|---|---|
| Ver dashboard | ✅ | ✅ | ✅ |
| Crear/editar candidatos | ✅ | ✅ | ❌ |
| Crear/editar posiciones | ✅ | ✅ | ❌ |
| Crear/editar empresas | ✅ | ❌ | ❌ |
| Generar ternas | ✅ | ✅ | ❌ |
| Crear cotizaciones | ✅ | ❌ | ❌ |
| Crear facturas | ✅ | ❌ | ❌ |
| Ver reportes | ✅ | ✅ | ✅ |
| Gestionar usuarios | ✅ | ❌ | ❌ |
| Configuración | ✅ | ❌ | ❌ |

Fase 1: solo existe el rol admin. La estructura RLS en Supabase queda preparada para agregar roles.

---

## 5. Flujos de estado

### Candidato por posición
```
Identificado → Enviado → En entrevista → Aprobado → Contratado
                                       → Rechazado → Disponible (activo para otras posiciones)
```

### Posición
```
Abierta → En proceso → Cubierta
                     → Cancelada
```

### Cotización
```
Borrador → Enviada → Aceptada
                   → Rechazada
```

### Factura
```
Enviada → Pendiente → Cobrada
                    → Vencida (automático por fecha)
```

---

## 6. Archivos HTML planificados

| Archivo | Módulo | Descripción |
|---|---|---|
| `index.html` | Dashboard | Vista principal, métricas, accesos rápidos |
| `candidatos.html` | Candidatos | Lista, búsqueda, filtros, crear/editar candidato |
| `candidato-detalle.html` | Candidatos | Perfil completo del candidato, evaluación, historial de posiciones |
| `posiciones.html` | Posiciones | Lista de posiciones con estados, filtros por empresa |
| `posicion-detalle.html` | Posiciones | Detalle de posición, candidatos asignados, terna |
| `empresas.html` | Empresas | Lista de empresas-cliente |
| `empresa-detalle.html` | Empresas | Dashboard de empresa: posiciones, candidatos, facturas |
| `ternas.html` | Ternas | Gestión de ternas, generación de PDF |
| `cotizaciones.html` | Cotizaciones | Lista y creación de cotizaciones, generación PDF |
| `facturas.html` | Facturación | Lista de facturas, aging, estados |
| `reportes.html` | Reportes | Métricas: colocación, tiempos, ingresos |
| `configuracion.html` | Configuración | Datos empresa, usuarios (fase 2) |
| `login.html` | Auth | Login con Supabase Auth |

---

## 7. Generación de PDFs

El portal genera tres tipos de PDF con la marca We Recruit:

1. **Reporte de terna:** Portada con logo, una página por candidato (foto, datos, evaluación en estrellas, notas), tabla comparativa final. Usa la plantilla ya definida en el proyecto "Terna de Candidatos".

2. **Cotización:** Datos de We Recruit, datos del cliente (nombre, RNC, dirección), desglose (puesto, salario mensual, fee = 1 mes de salario, total), fecha, número de cotización.

3. **Factura:** Similar a cotización pero con número de factura, fecha de emisión, fecha de vencimiento, datos bancarios para pago.

**Paleta de marca para PDFs:**
- Azul oscuro: #063958
- Azul medio: #0F6B9F
- Verde menta: #CEE4CC

---

## 8. Reportes y métricas

| Métrica | Cálculo |
|---|---|
| Tasa de colocación | Candidatos contratados / candidatos enviados |
| Tiempo promedio de llenado | Días entre apertura y colocación por posición |
| Ingresos por mes | Suma de facturas cobradas en el mes |
| Ingresos por cliente | Suma de facturas cobradas agrupadas por empresa |
| Aging de cuentas por cobrar | Facturas pendientes agrupadas por rango de días (0-30, 31-60, 61-90, 90+) |
| Reporte mensual de facturación | Facturado vs. cobrado vs. pendiente en el mes |

---

## 9. Prioridad de desarrollo

| Fase | Módulos | Razón |
|---|---|---|
| **Fase 1** | Login, Candidatos, Posiciones, Dashboard básico | Corazón de la operación. Dejar de perder candidatos y tener visibilidad |
| **Fase 2** | Empresas-cliente, Ternas (con PDF) | Organizar la relación con clientes y automatizar envíos |
| **Fase 3** | Cotizaciones, Facturación, Reportes | Control financiero y cobros |
| **Fase 4** | Herramienta de evaluación psicométrica propia | Cuestionario que llena el candidato desde un link, mezcla DISC + metodología Svetlana |
| **Fase 5** | Roles y usuarios adicionales | Cuando We Recruit crezca |

---

## 10. Pendientes y notas

- La herramienta de evaluación psicométrica (fase 4) necesita una sesión de discovery aparte para definir las preguntas, la metodología de scoring y cómo se presenta el resultado.
- Los logos de marca (azul marino, azul claro, verde claro) ya están guardados en `Projects/Terna de Candidatos/documentos-referencia/`.
- Svetlana tiene un formato PDF de cotización existente que puede servir de referencia para el diseño.
- El campo `documento_acuerdo_url` en empresas permite vincular contratos o acuerdos de servicio. No es obligatorio.
