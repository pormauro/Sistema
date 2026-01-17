# **📘 FASE 2 — SISA ERP**

## **PASO 2 — DOCUMENTACIÓN OPERATIVA COMPLETA Y DEFINITIVA**

**Contrato de arquitectura • Sin código • Sin SQL • Sin implementación**

---

# **🧭 0\. PROPÓSITO DE LA FASE 2**

FASE 2 define el **ERP Operativo**:

* registra hechos operativos reales  
* organiza relaciones entre empresas  
* maneja tiempos, estados y responsabilidades  
* produce datos **consistentes, inmutables y auditables**  
* prepara la información para que **ACCCORE (Fase 3\)** genere contabilidad

FASE 2 **no interpreta**, solo **registra**.

---

# **🧱 1\. PRINCIPIOS RECTORES (INAMOVIBLES)**

### **1.1 No existe borrado físico**

Todo registro permanece.  
Solo existe:

* `status`  
* `deleted_at`  
* estados terminales (`cancelled`, `voided`, `completed`, etc.)

### **1.2 Regla 4equim (Padre–Hijo)**

No se puede cerrar o invalidar un padre si hay hijos activos contradictorios:

Ejemplos:

* una factura `issued` no puede `voided` si tiene receipts `completed`  
* una venta no puede `cancelled` si tiene invoice activa  
* un job no puede eliminarse si tiene ejecución

### **1.3 Audit Trail Obligatorio**

Toda acción significativa genera:

* actor  
* timestamp  
* entidad \+ id  
* estado anterior → nuevo  
* motivo (si aplica)  
* dependencias vinculadas

Intentos bloqueados **también se auditan**.

### **1.4 Idempotencia real**

La misma operación repetida:

* no duplica efectos  
* responde “ok, ya estaba hecho”  
* se puede registrar como no-op relevante

### **1.5 Estados terminales**

No retroceden:

* `completed`  
* `cancelled`  
* `voided`  
* `reversed`  
* `deleted`

### **1.6 Inmutabilidad de datos operativos**

Una vez emitidos/confirmados:

❌ No se modifican importes  
❌ No se cambian ítems  
❌ No se cambian fechas reales  
✔ Se permiten **ajustes** mediante eventos explícitos

---

# **🧱 2\. CLIENTES Y PROVEEDORES — DEFINICIÓN FINAL**

**No existen tablas clients ni providers.**

Regla absoluta:

Cliente y proveedor son solamente **roles** de una **empresa existente en la tabla `companies`**.

Referencias válidas:

* `client_company_id` → `companies.id`  
* `provider_company_id` → `companies.id`

Una empresa puede ser:

* cliente  
* proveedor  
* ambas  
* ninguna

No se duplican datos.  
No se reescribe CUIT.  
No se generan inconsistencias legales.

---

# **🧱 3\. ENTIDADES OPERATIVAS DE FASE 2**

FASE 2 define:

* **Sales** (ventas operativas)  
* **Purchases** (compras operativas)  
* **Quotes** (presupuestos)  
* **Jobs** (órdenes de trabajo)  
* **Invoices** (documento operativo)  
* **Receipts** (cobros)  
* **Payments** (pagos)  
* **Adjustments** (ajustes operativos)

Todas:

* pertenecen a una empresa  
* tienen lifecycle  
* generan auditoría  
* respetan regla 4equim  
* NO generan asientos contables  
* NO interpretan fiscalidad

---

# **🧱 4\. LIFECYCLE POR ENTIDAD**

(Máquinas de estado completas, definitivas)

---

# **4.1 JOBS / WORK ORDERS — Modelo Final**

## **Estados válidos**

* `planned`  
* `in_progress`  
* `paused`  
* `completed` (terminal)  
* `cancelled` (terminal)

## **❌ Transiciones prohibidas**

* `completed → *`  
* `cancelled → *`  
* `in_progress → planned`  
* `paused → planned` (NO permitido)

## **✔ Transiciones válidas**

* `planned → in_progress`  
* `planned → cancelled`  
* `in_progress → paused`  
* `paused → in_progress`  
* `in_progress → completed`  
* `paused → completed` (requiere evidencia real)

## **Precondiciones obligatorias**

### **Para `planned → in_progress`**

* transición **automática** al crear el primer `job_time_entry`  
* responsable asignado  
* tipo de job definido  
* empresa activa

### **Para `in_progress → completed`**

Debe existir evidencia:

* timestamps reales de inicio/fin  
* tareas ejecutadas  
* tiempos registrados  
* evento explícito de cierre

### **Cancelación**

* desde `planned`: libre con motivo  
* desde `in_progress`: permitido con evidencia \+ motivo  
  (no se borra lo ya ejecutado)

## **Regla dura: actividad real vs estado**

* la creación del **primer `job_time_entry`** fuerza el estado a `in_progress`  
* no existe trabajo real sin job activo  

---

## **Checklist — ejecución real (modelo aprobado)**

El checklist **no existe en abstracto**.  
Existe cuando alguien lo ejecuta en un tramo real de trabajo.

```text
job_checklist_execution
- checklist_item_id
- job_time_entry_id
- executed_by_user_id
- executed_at
```

Reglas:

* un mismo item puede ejecutarse múltiples veces  
* cada ejecución queda vinculada a un `job_time_entry` real  

---

# **4.2 MODIFICACIÓN DE FECHAS — SOLUCIÓN FINAL Y UNIVERSAL**

### **Principio duro**

El pasado NO se edita.  
Se corrige agregando historia.

### **Tipos de fechas**

* **planificadas** → editables  
* **reales** → inmutables  
* **correcciones** → eventos

## **Cómo se modifica:**

### **Estado `planned`**

✔ puede cambiar fechas sin restricciones  
✔ auditado

### **Estados `in_progress` / `paused`**

❌ NO se edita lo que ya ocurrió  
✔ se ajusta lo futuro  
✔ se registra **schedule\_adjusted**

### **Estado `completed`**

❌ No se puede tocar  
✔ solo ajustes mediante eventos: `job_time_correction_applied`

## **Corrección contable de tiempos (modelo definitivo)**

**Regla dura:**

* `job_time_entries` **NO se editan ni se eliminan**  
* toda corrección se registra como **evento de ajuste**

**Modelo lógico:**

* `job_time_entries` → evento original  
* `job_time_adjustments` → correcciones posteriores

**Campos mínimos del ajuste:**

* `adjustment_of_time_entry_id`  
* `delta_minutes`  
* `reason`  
* `adjusted_by_user_id`  
* `adjusted_at`

**Cálculo total:**

```
SUM(job_time_entries.minutes) + SUM(job_time_adjustments.delta_minutes)
```

---

# **4.3 SALES**

## **Estados**

* `draft`  
* `confirmed`  
* `cancelled` (terminal)

## **Transiciones válidas**

* `draft → confirmed`  
* `draft → cancelled`  
* `confirmed → cancelled` (si no tiene invoice o receipts activos)

## **Precondiciones para `draft → confirmed`**

* company activa  
* client\_company\_id válido  
* items \> 0  
* moneda definida  
* fecha operativa

---

# **4.4 PURCHASES**

Simétrico a Sales:

* `draft → confirmed`  
* `draft → cancelled`  
* `confirmed → cancelled` (sin pagos ni documentos activos)

---

# **4.5 QUOTES (PRESUPUESTOS)**

## **Estados**

* `draft`  
* `sent`  
* `accepted`  
* `rejected`  
* `expired` (terminal)

## **Transiciones**

* `draft → sent`  
* `sent → accepted`  
* `sent → rejected`  
* `sent → expired`

Accepted → terminal lógico (no vuelve atrás)

---

# **4.6 INVOICES (Documento operativo)**

## **Estados**

* `draft`  
* `issued`  
* `voided`

## **Transiciones válidas**

* `draft → issued`  
* `draft → voided`  
* `issued → voided` (sin receipts completed)

---

# **4.7 RECEIPTS (Cobros)**

## **Estados**

* `pending`  
* `completed`  
* `reversed`

## **Transiciones válidas**

* `pending → completed`  
* `pending → reversed`  
* `completed → reversed`

---

# **4.8 PAYMENTS (Pagos)**

Simétrico a receipts.

---

# **4.9 ADJUSTMENTS (Ajustes operativos)**

Se usan para:

* corregir tiempos reales  
* corregir datos históricos relevantes  
* sin reescribir el registro original

Estados:

* `draft`  
* `applied` (terminal)  
* `cancelled`

---

# **🧱 5\. VALIDACIONES CRUZADAS DEL ERP**

### **5.1 Dependencias inconsistentes (bloquea)**

Ejemplos:

* invoice con receipt → no se puede voided  
* sale con invoice → no se puede cancelar  
* purchase con payment → no se puede cancelar

### **5.2 Temporalidad**

No se puede reescribir:

* fechas reales  
* eventos pasados  
* operaciones ya emitidas/confirmadas

### **5.3 Empresas inactivas**

Si `company.status != active`:

* no se pueden crear operaciones nuevas  
* solo lectura y archivado

---

# **🧱 6\. AUDITORÍA OBLIGATORIA**

Cada transición o cambio relevante genera:

* actor  
* timestamp  
* estado anterior / nuevo  
* payload de cambios  
* motivo (si corresponde)  
* ids referenciados  
* no-op si corresponde

Cambios temporales SIEMPRE auditan valor anterior y nuevo.

---

# **🧱 7\. EVENTOS OPERATIVOS**

(Base para ACCCORE)

FASE 2 genera eventos como:

* `job_started`  
* `job_paused`  
* `job_completed`  
* `job_cancelled`  
* `schedule_adjusted`  
* `sale_confirmed`  
* `invoice_issued`  
* `receipt_completed`  
* `payment_completed`  
* `correction_applied`  
* etc.

Estos eventos:

* son inmutables  
* no se modifican  
* son el insumo de ACCCORE  
* no contienen lógica contable

---

# **🧱 8\. RELACIÓN FASE 2 → FASE 3**

FASE 2:

* registra hechos brutos  
* mantiene historia limpia  
* garantiza trazabilidad completa

FASE 3:

* lee eventos  
* genera asientos  
* aplica fiscalidad y reglas contables

FASE 2 NO incluye:

* cuentas contables  
* IVA  
* percepciones  
* amortización  
* resultados  
* cashflow contable

---
