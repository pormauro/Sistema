# Offline Strategy — SISA

## 🎯 Objetivo

Definir **cuándo**, **dónde** y **por qué** SISA aplica el enfoque **offline-first**, evitando inconsistencias, riesgos contables o violaciones de reglas de negocio.

SISA **no es offline-first por defecto**.  
Es **offline-inteligente**.

---

## 🧠 Principio rector

> **Si el dato representa un hecho ocurrido → puede ser offline-first**  
> **Si el dato representa una verdad del sistema → es online-only**

Este principio gobierna todas las decisiones offline del sistema.

---

## ✅ Casos donde SÍ aplica Offline-first

### 1. Jobs en ejecución

**Contexto**  
Operación en campo con conectividad inestable o inexistente.

**Acciones permitidas offline**
- Visualización de Jobs asignados
- Transiciones operativas:
  - `planned → in_progress`
  - `in_progress → paused`
- Registro de observaciones
- Asociación de participantes
- Registro de tramos horarios
- Adjuntar archivos

**Estrategia**
- Cache local estructurada
- Cola de eventos append-only
- Sincronización diferida con validación de estado

---

### 2. Checklists / Consignas operativas

**Descripción**
- Ítems ejecutables
- Pueden realizarse múltiples veces por Job
- Asociados al momento real de ejecución

**Offline**
- Ejecución completa offline
- Persistencia local con timestamp real
- Sincronización posterior

---

### 3. Tiempos trabajados

**Características**
- Registro de inicio / fin
- Múltiples tramos por Job
- Correcciones permitidas con historial

**Offline**
- Captura local
- Validación en sincronización
- Nunca se pisa historial existente

---

### 4. Captura de archivos

**Ejemplos**
- Fotos de equipos
- Videos de fallas
- Evidencias técnicas

**Flujo**
1. Guardado local
2. Asociación de metadata
3. Upload diferido
4. Vinculación al Job / checklist correspondiente

---

### 5. Datos de referencia (solo lectura)

**Ejemplos**
- Clientes
- Productos / servicios
- Carpetas
- Estados válidos

**Restricción**
- Lectura offline permitida
- Creación y edición **solo online**

---

## ❌ Casos donde NO aplica Offline-first

### 1. Contabilidad

**Prohibido offline**
- Asientos contables
- Pagos
- Facturación
- Cierres
- Ajustes

**Motivo**
- Riesgo financiero
- Riesgo legal
- Alta dependencia cruzada

---

### 2. Estados finales de Jobs

Estados:
- `completed`
- `cancelled`

**Regla**
- Nunca se confirman offline
- Pueden proponerse, pero requieren validación online

---

### 3. Usuarios y permisos

**Incluye**
- Creación de usuarios
- Asignación de roles
- Vinculación a empresas

**Motivo**
- Riesgo de escalamiento de privilegios
- Seguridad del sistema

---

### 4. Datos maestros estructurales

**Ejemplos**
- Empresas
- Clientes / proveedores
- Productos / servicios
- Configuración global
- Estructuras contables

**Regla**
- Siempre online

---

## 🧱 Política de sincronización

- Todos los eventos offline:
  - Son **append-only**
  - Nunca pisan datos existentes
  - Se validan contra el estado actual
- Conflictos:
  - Se rechazan eventos inválidos
  - Se registran para auditoría
- El servidor es la **fuente de verdad final**
- No existe “rebobinado” de estado:
  - El servidor evalúa cada evento contra el **estado actual**
  - Un evento puede ser válido al crearse y **rechazado al sincronizar**
  - Esto es esperado, no un error

---

## 🔍 Auditoría

Cada evento offline sincronizado:
- Tiene timestamp local
- Tiene timestamp de servidor
- Guarda autor, contexto y entidad afectada
- Nunca se elimina
- Las reglas se evalúan con tiempo de servidor (primario)
- El tiempo local es referencial y **no se corrige**

---

## ⚠️ Advertencias

- Offline-first mal aplicado **rompe sistemas**
- No se admiten “excepciones por comodidad”
- Offline **no garantiza finalización**, solo registro del intento
- Si una acción afecta:
  - dinero
  - estructura
  - permisos  
  entonces **no es offline**

---

## ✅ Conclusión

SISA aplica offline-first **solo donde agrega valor real**, sin comprometer:

- consistencia
- seguridad
- auditabilidad
- escalabilidad

Offline no es libertad.  
Es **responsabilidad controlada**.

---
