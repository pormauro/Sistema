# Offline Scope Boundary — SISA

## 🎯 Objetivo

Definir **límites explícitos e inquebrantables** sobre qué **nunca** puede implementarse en modo offline dentro de SISA.

Este documento existe para:
- prevenir degradación arquitectónica
- evitar “excepciones cómodas”
- proteger el core del sistema a largo plazo

---

## 🧠 Principio absoluto

> **El offline no define verdad, solo registra intentos.**

Cualquier funcionalidad que contradiga este principio  
**queda automáticamente fuera de alcance**.

---

## 🚫 Categorías prohibidas para Offline

Las siguientes categorías **no pueden** operar offline, **bajo ningún escenario**.

---

### 1️⃣ Dinero y contabilidad

Incluye (sin excepción):

- Asientos contables
- Pagos
- Cobros
- Facturación
- Notas de crédito / débito
- Cierres contables
- Ajustes de balance
- Reversiones financieras

**Motivo**
- Riesgo legal
- Riesgo fiscal
- Dependencias cruzadas
- Impacto irreversible

❌ Nunca offline  
❌ Nunca “modo borrador” offline  
❌ Nunca sincronización diferida

---

### 2️⃣ Estados terminales

Estados finales o irreversibles:

- `completed`
- `cancelled`
- `closed`
- `archived`

**Motivo**
- Disparan efectos colaterales
- Pueden cerrar flujos contables u operativos
- Definen historia final

✔ Pueden **proponerse** offline  
❌ Nunca confirmarse offline

---

### 3️⃣ Datos maestros estructurales

Incluye:

- Empresas
- Clientes
- Proveedores
- Productos / servicios
- Carpetas raíz
- Configuración global
- Catálogos base

**Motivo**
- Alta dependencia
- Riesgo de duplicación
- Rompen integridad referencial

❌ No se crean offline  
❌ No se editan offline  
❌ No se eliminan offline

---

### 4️⃣ Seguridad y permisos

Incluye:

- Creación de usuarios
- Cambios de rol
- Asignación de empresas
- Revocación de accesos
- Políticas de seguridad

**Motivo**
- Riesgo de escalamiento de privilegios
- Violación de modelo de seguridad

❌ Nunca offline  
❌ Nunca cache editable

---

### 5️⃣ Configuración del sistema

Incluye:

- Parámetros globales
- Reglas de negocio
- Máquinas de estado
- Flags de comportamiento

**Motivo**
- Cambios sistémicos
- Impacto transversal
- Difícil rollback

---

## ⚠️ Zonas grises explícitamente cerradas

Las siguientes ideas **parecen razonables**, pero están **prohibidas**:

- “Modo borrador offline” para facturas
- “Pre-crear clientes offline”
- “Cerrar trabajos offline y confirmar después”
- “Editar permisos sin conexión”
- “Sincronizar contabilidad al reconectar”

Si alguien propone esto:
👉 la respuesta es **NO**.

---

## ✅ Categorías permitidas Offline (recordatorio)

El offline **solo** se admite para:

- Registro de acciones operativas
- Checklists
- Tiempos trabajados
- Archivos y evidencias
- Observaciones
- Lectura de datos de referencia

Siempre bajo:
- cola de eventos
- validación server-side
- auditoría

---

## 🧱 Regla de decisión rápida

Ante cualquier feature nueva, preguntarse:

1. ¿Afecta dinero?
2. ¿Define una verdad del sistema?
3. ¿Cambia permisos o estructura?
4. ¿Es irreversible?

Si la respuesta es **sí** a cualquiera:
👉 **No es offline**.

---

## 🔐 Autoridad final

- Este documento **tiene prioridad** sobre:
  - decisiones de UX
  - pedidos comerciales
  - conveniencias técnicas
- Ninguna feature puede violarlo sin **romper SISA**

---

## ✅ Conclusión

El offline en SISA:

- es acotado
- es consciente
- es responsable
- es defendible

Este boundary existe para que el sistema **no se desarme con el tiempo**.

---
