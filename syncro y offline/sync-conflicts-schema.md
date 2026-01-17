# sync_conflicts — Schema Definition (SISA)

## 🎯 Objetivo

Definir la estructura de la tabla `sync_conflicts`, encargada de **registrar de forma inmutable** todos los conflictos detectados durante la sincronización de eventos offline.

Esta tabla es **parte del sistema de auditoría** y **no admite borrado ni edición**.

---

## 🧠 Principios de diseño

- Append-only
- Auditoría completa
- Multi-empresa real
- No depende del estado actual para interpretarse
- Reconstrucción histórica posible sin ambigüedades

---

## 🗄 Tabla: sync_conflicts

### Campos obligatorios

| Campo | Tipo | Descripción |
|-----|-----|------------|
| `id` | UUID | Identificador único del registro de conflicto |
| `event_id` | UUID | ID del evento offline que generó el conflicto |
| `company_id` | UUID | Empresa en la que ocurrió el conflicto |
| `entity_type` | VARCHAR | Tipo de entidad afectada (job, checklist_item, time_entry, file, etc.) |
| `entity_id` | UUID | ID de la entidad afectada |
| `conflict_type` | VARCHAR | Clasificación del conflicto |
| `action` | VARCHAR | Acción intentada (ej: job_paused) |
| `payload` | JSON | Payload original del evento offline |
| `user_id` | UUID | Usuario que generó el evento |
| `device_id` | VARCHAR | Identificador del dispositivo |
| `local_timestamp` | DATETIME | Timestamp generado en el dispositivo |
| `server_timestamp` | DATETIME | Timestamp del servidor al procesar |
| `rejection_reason` | TEXT | Motivo técnico del rechazo |
| `created_at` | DATETIME | Momento de inserción del registro |

---

## 🧾 conflict_type — valores esperados

`conflict_type` **no es libre**, debe responder a un set controlado.

Valores recomendados:

- `invalid_state`
- `invalid_transition`
- `permission_denied`
- `temporal_inconsistency`
- `duplicate_event`
- `structural_conflict`
- `unknown_entity`
- `validation_error`

> ❗ No se usan enums rígidos para permitir evolución controlada.

---

## 🔗 Relaciones conceptuales

- `event_id` → offline_events.event_id
- `company_id` → companies.id
- `user_id` → users.id
- `entity_id` → entidad correspondiente según `entity_type`

⚠️ **No se usan foreign keys obligatorias**  
Motivo: la entidad puede haber sido eliminada virtualmente.

---

## 🧱 Reglas duras

- Ningún registro se elimina
- Ningún registro se modifica
- No se reutiliza `event_id`
- Un mismo evento genera **máximo un conflicto**
- La ausencia de `company_id` invalida el registro

---

## 🔐 Retención y acceso

- Retención: **indefinida**
- Acceso:
  - solo admins
  - solo lectura
  - nunca editable
- No visible para usuarios finales estándar

---

## 🔍 Casos de uso cubiertos

- Auditoría legal
- Debugging técnico
- Soporte al usuario
- Análisis de fallas offline
- Métricas de calidad de sincronización

---

## ⚠️ Errores que este schema evita

- Conflictos sin contexto empresarial
- Logs ambiguos
- Reescritura de historia
- Debugging basado en suposiciones
- “Funcionó en mi teléfono”

---

## ✅ Conclusión

La tabla `sync_conflicts` es:

- un registro de verdad
- una defensa técnica
- una herramienta legal
- un seguro contra corrupción silenciosa

Si esta tabla existe y se respeta, el offline **no miente**.

---
