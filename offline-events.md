# Offline Events Queue — SISA

## 🎯 Objetivo

Definir el **modelo de cola de eventos offline** utilizado por SISA para registrar acciones realizadas sin conectividad y sincronizarlas de forma **segura**, **auditable** y **determinista**.

Esta cola es la **única vía válida** para introducir cambios offline al sistema.

---

## 🧠 Principios no negociables

- La cola es **append-only**
- Los eventos **no se editan**
- Los eventos **no se eliminan**
- El servidor es la **fuente de verdad final**
- El orden importa
- La validación siempre ocurre **en el servidor**

---

## 🧱 Concepto central

Un **Offline Event** representa **una acción del usuario**, no un estado final.

Ejemplo:
- ✔ “El usuario inició el trabajo”
- ❌ “El trabajo quedó en progreso”

---

## 🧾 Estructura lógica de un Offline Event

Cada evento contiene:

- `event_id` — UUID único
- `entity_type` — Job, ChecklistItem, TimeEntry, File
- `entity_id` — ID de la entidad afectada
- `action` — Acción ejecutada
- `payload` — Datos mínimos necesarios
- `actor_user_id`
- `company_id`
- `device_id`
- `local_timestamp`
- `sequence_number`
- `status` — pending / synced / rejected
- `hash` — integridad del evento

---

## 🧮 Orden y secuencia

- Cada dispositivo mantiene un `sequence_number` incremental
- El servidor valida:
  - duplicados
  - saltos de secuencia
  - reenvíos
- El orden de procesamiento es **estricto por dispositivo**
- No existe orden global entre dispositivos
- Los conflictos inter-dispositivo se resuelven contra el estado actual
- No existe “lock offline”

---

## 🧩 Identidad del dispositivo

- `device_id` se registra y **no se recicla**
- Revocar un dispositivo:
  - invalida eventos futuros
  - **no invalida eventos pasados**

---

## 🔄 Tipos de eventos permitidos

### Jobs
- `job_started`
- `job_paused`
- `job_resumed`
- `job_note_added`

### Checklists
- `checklist_item_completed`
- `checklist_item_failed`
- `checklist_item_note_added`

### Tiempos
- `time_entry_started`
- `time_entry_stopped`
- `time_entry_corrected`

### Archivos
- `file_captured`
- `file_metadata_updated`

---

## ❌ Eventos explícitamente prohibidos offline

- `job_completed`
- `job_cancelled`
- `accounting_entry_created`
- `invoice_created`
- `user_created`
- `role_changed`

Estos eventos **solo existen online**.

---

## 🔍 Validación en el servidor

Cada evento es validado contra:

- Estado actual de la entidad
- Máquina de estados
- Permisos del usuario
- Empresa activa
- Consistencia temporal
- Duplicación

Resultado:
- **Aceptado** → aplicado + marcado como synced
- **Rechazado** → marcado como rejected + auditado

---

## ⚠️ Manejo de conflictos

Ejemplos:
- Evento aplicado sobre estado inválido
- Evento duplicado
- Evento fuera de orden

Regla:
- El evento **no se reintenta automáticamente**
- Se registra el rechazo
- Se notifica al usuario

---

## 🧾 Auditoría

Cada evento queda registrado con:

- Payload original
- Timestamps (local + server)
- Resultado de validación
- Motivo de rechazo (si aplica)

Nunca se borra.

---

## 🧱 Persistencia local

- Base local (SQLite / almacenamiento seguro)
- Cola transaccional
- Confirmación explícita de sync
- Soporte para reintentos manuales
- La cola offline es **volátil por diseño**
- La app **no garantiza** persistencia cross-install
- Si el usuario reinstala, asume la pérdida de eventos
- Esto debe informarse explícitamente en UX

---

## 🔐 Seguridad

- Eventos firmados con hash
- Asociados a dispositivo y usuario
- No se aceptan eventos sin autenticación previa válida

---

## ✅ Conclusión

La cola de eventos offline en SISA:

- No intenta “recrear estados”
- No corrige el pasado
- No asume autoridad

Solo **narra hechos**.

El servidor decide qué hechos son válidos.

---
