# Sync Conflict Policy — SISA

## 🎯 Objetivo

Definir **cómo SISA detecta, clasifica y resuelve conflictos** durante la sincronización de eventos offline, garantizando:

- consistencia
- auditabilidad
- previsibilidad
- ausencia de efectos colaterales silenciosos

En SISA **no existen conflictos “automágicos”**.

---

## 🧠 Principio rector

> **El servidor es la única fuente de verdad.**  
> El cliente offline **propone hechos**, el servidor **decide validez**.

---

## 🧩 Qué es un conflicto

Un conflicto ocurre cuando un **evento offline**:

- contradice el estado actual del sistema
- viola una regla de negocio
- llega fuera de contexto temporal
- fue generado sin permisos válidos
- ya fue aplicado (duplicado)

---

## 🧱 Clasificación de conflictos

### 1️⃣ Conflicto de estado

**Descripción**  
El evento intenta aplicarse sobre un estado inválido.

**Ejemplo**
- Evento: `job_paused`
- Estado actual: `planned`

**Resolución**
- ❌ Evento rechazado
- 📄 Motivo registrado
- 🔔 Usuario notificado

---

### 2️⃣ Conflicto de transición prohibida

**Descripción**  
La acción viola la máquina de estados.

**Ejemplo**
- Evento: `job_resumed`
- Estado actual: `completed`

**Resolución**
- ❌ Evento rechazado
- 📄 Auditoría completa
- ❌ No se reintenta

---

### 3️⃣ Conflicto de permisos

**Descripción**
El usuario no tiene permisos válidos al momento de sincronizar.

**Ejemplo**
- Usuario removido de la empresa
- Rol degradado

**Resolución**
- ❌ Evento rechazado
- 🔒 Seguridad prioritaria
- 📄 Registro de intento

---

### 4️⃣ Conflicto temporal

**Descripción**
El evento presenta incoherencias de tiempo.

**Ejemplos**
- Fin antes del inicio
- Superposición imposible de tramos
- Timestamp inválido

**Resolución**
- ❌ Evento rechazado
- 📄 Se conserva el payload original
- 🔔 Usuario informado

---

### 5️⃣ Conflicto de duplicación

**Descripción**
El evento ya fue procesado.

**Detección**
- `event_id`
- `hash`
- `sequence_number`

**Resolución**
- ⚠️ Evento ignorado
- ✔ Marcado como synced
- 📄 Sin efectos colaterales

---

### 6️⃣ Conflicto estructural

**Descripción**
La entidad referenciada ya no existe o cambió su contexto.

**Ejemplo**
- Job eliminado virtualmente
- Checklist deshabilitado

**Resolución**
- ❌ Evento rechazado
- 📄 Registro obligatorio

---

## 🔄 Política de resolución

| Tipo de conflicto | Acción |
|------------------|-------|
| Estado inválido | Rechazo |
| Transición prohibida | Rechazo |
| Permisos | Rechazo |
| Temporal | Rechazo |
| Duplicado | Ignorar |
| Estructural | Rechazo |

❗ **Nunca se corrige un evento automáticamente**  
❗ **Nunca se reescribe la historia**

---

## 🔁 Reintentos

- ❌ No hay reintentos automáticos
- ✔ El usuario puede:
  - revisar el motivo
  - repetir la acción manualmente
  - generar un nuevo evento válido

Cada reintento es **un evento nuevo**, no una modificación.

---

## 🧾 Auditoría de conflictos

Todo conflicto genera:

- ID del evento
- Tipo de conflicto
- Payload original
- Usuario
- Empresa
- Dispositivo
- Timestamp local y de servidor
- Motivo técnico del rechazo

Estos registros **no se eliminan**.

---

## 🔔 Comunicación al usuario

El sistema debe:

- Informar claramente el rechazo
- Explicar el motivo en lenguaje operativo
- Evitar mensajes genéricos

Ejemplo válido:
> “El trabajo ya fue completado por otro usuario antes de sincronizar.”

Ejemplo inválido:
> “Error de sincronización.”

---

## 🔐 Seguridad

- Un evento rechazado **no degrada** el sistema
- No se bloquea la cola completa
- Cada evento se evalúa individualmente
- No hay escalamiento de privilegios offline

---

## 🧠 Filosofía final

SISA **prefiere rechazar un evento válido**  
antes que **aceptar uno incorrecto**.

La integridad del sistema **está por encima de la comodidad del usuario**.

---

## ✅ Conclusión

La política de conflictos de SISA garantiza que:

- el offline no corrompe el core
- los errores son visibles
- el sistema es defendible
- la historia nunca se reescribe

Sin esta política, el offline es una mentira peligrosa.

---
