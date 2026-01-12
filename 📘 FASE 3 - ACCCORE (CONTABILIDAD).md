---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **PASO 3.1 — FUNDAMENTOS Y ORDEN DE CONSTRUCCIÓN CONTABLE**

**Contrato de arquitectura contable — Sin código**

---

## **🎯 PROPÓSITO DE ACCCORE**

ACCCORE es el **núcleo contable** del sistema.

Su función es:

* interpretar hechos operativos del ERP (FASE 2\)  
* generar información contable legal y consistente  
* mantener trazabilidad completa evento → asiento  
* permitir reconstrucción histórica  
* soportar auditoría y fiscalidad

👉 **ACCCORE NO REGISTRA HECHOS**  
👉 **ACCCORE INTERPRETA HECHOS YA CERRADOS**

---

## **🧱 PRINCIPIO MADRE (NO NEGOCIABLE)**

**NO EXISTE CONTABILIDAD SIN EVENTOS OPERATIVOS PREVIOS**

ACCCORE:

* no recibe inputs directos de UI  
* no recibe “crear asiento” manual libre  
* no corrige el pasado  
* no depende de estados actuales, sino de eventos históricos

---

## **🧱 ORDEN REAL DE IMPLEMENTACIÓN CONTABLE**

1\) Modelo contable base

2\) Plan de cuentas

3\) Periodos contables

4\) Motor de asientos

5\) Mayor contable

6\) Cierres

7\) Reportes

Este orden **NO se altera**.

---

## **🧱 1️⃣ MODELO CONTABLE BASE**

### **Entidades conceptuales mínimas**

* Account (Cuenta contable)  
* AccountingPeriod (Periodo)  
* JournalEntry (Asiento)  
* JournalLine (Debe / Haber)  
* AccountingEventLink (vínculo a evento ERP)

👉 **Nada más al principio**.

---

## **🧱 2️⃣ PLAN DE CUENTAS**

### **Reglas duras**

* Plan único por empresa  
* Cuentas jerárquicas  
* Cuentas:  
  * activo  
  * pasivo  
  * patrimonio  
  * resultados  
* No se eliminan  
* Se archivan  
* Se versionan implícitamente por uso histórico

### **Estado de cuentas**

* active  
* archived

---

## **🧱 3️⃣ PERIODOS CONTABLES**

### **Concepto**

La contabilidad se organiza en **periodos cerrables**:

* mensual (base)  
* anual (agrupación)

### **Reglas**

* Un asiento pertenece a un solo periodo  
* Periodo cerrado:  
  * no admite nuevos asientos  
  * no admite modificaciones  
* Reapertura:  
  * solo owner  
  * evento auditado

---

## **🧱 4️⃣ MOTOR DE ASIENTOS (CORE CONTABLE)**

### **Función**

Transformar **eventos ERP** en **asientos contables**.

### **Reglas críticas**

* Cada evento ERP:  
  * puede generar 0, 1 o N asientos  
* Un evento:  
  * se procesa una sola vez (idempotencia)  
* Cada asiento:  
  * está vinculado al evento origen  
* Debe \= Haber (siempre)

👉 **No hay asientos “sueltos”**

---

## **🧱 5️⃣ MAYOR CONTABLE**

### **Función**

Acumulación histórica de movimientos:

* por cuenta  
* por periodo  
* por empresa

### **Reglas**

* El mayor es **derivado**, no fuente  
* Nunca se edita manualmente  
* Se recalcula si es necesario

---

## **🧱 6️⃣ CIERRES CONTABLES**

### **Proceso**

1. Validar periodos  
2. Verificar balance  
3. Cerrar periodo  
4. Bloquear escrituras  
5. Emitir evento `period_closed`

### **Reglas**

* Periodo cerrado es inmutable  
* Ajustes posteriores:  
  * se hacen en periodos futuros  
* Nunca se reescribe el pasado

---

## **🧱 7️⃣ REPORTES (NO MVP AÚN)**

Derivan de mayor \+ plan:

* Balance  
* Estado de resultados  
* Libros legales

👉 **No se implementan antes de cerrar lo anterior**

---

## **🔐 AUTORIZACIÓN CONTABLE**

* Solo roles finos contables  
* Solo owner puede:  
  * cerrar periodos  
  * reabrir periodos  
* Admin:  
  * NO toca contabilidad  
* Member / Viewer:  
  * NO acceden

---

## **🧾 AUDITORÍA CONTABLE**

Debe existir trazabilidad completa:

Evento ERP → Asiento → Línea → Cuenta → Periodo

Nada puede romper esa cadena.

---

## **🚨 COSAS QUE NO SE HACEN (NUNCA)**

* ❌ Crear asientos desde UI  
* ❌ Editar asientos  
* ❌ Borrar asientos  
* ❌ Reabrir periodos sin auditoría  
* ❌ Mezclar contabilidad con ERP  
* ❌ Inferir contabilidad por estado actual

---

---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **PASO 3.2 — DISEÑO DEL PLAN DE CUENTAS BASE (ARGENTINA-READY)**

**Contrato de arquitectura contable — Sin código**

---

## **🎯 OBJETIVO**

Definir un **Plan de Cuentas base**, mínimo pero **legalmente válido en Argentina**, que:

* sea **genérico y reutilizable**  
* soporte **ERP multiempresa**  
* permita **reconstrucción histórica**  
* no mezcle fiscalidad con operación  
* escale sin romper compatibilidad

Este plan **no es el definitivo de cada empresa**, es el **baseline obligatorio**.

---

## **🧱 PRINCIPIOS INMUTABLES**

1. **Plan único por empresa**  
2. **Cuentas jerárquicas** (padre/hijo)  
3. **Nunca se borran cuentas**  
4. **Una cuenta usada no cambia de tipo**  
5. **El pasado no se reescribe**  
6. **La contabilidad nace del ERP, no del usuario**

---

## **🧱 ESTRUCTURA GENERAL DEL PLAN**

Clasificación contable estándar:

1 \- ACTIVO  
2 \- PASIVO  
3 \- PATRIMONIO NETO  
4 \- RESULTADOS (+)  
5 \- RESULTADOS (−)

Cada nivel admite **subniveles ilimitados**.

---

## **🧱 1️⃣ ACTIVO (1.x)**

### **1.1 Activo Corriente**

* 1.1.1 Caja  
* 1.1.2 Bancos  
* 1.1.3 Valores a Depositar  
* 1.1.4 Créditos por Ventas  
* 1.1.5 Otros Créditos  
* 1.1.6 IVA Crédito Fiscal  
* 1.1.7 Anticipos a Proveedores  
* 1.1.8 Mercaderías / Stock

### **1.2 Activo No Corriente**

* 1.2.1 Bienes de Uso  
* 1.2.2 Amortización Acumulada  
* 1.2.3 Inversiones  
* 1.2.4 Activos Intangibles

---

## **🧱 2️⃣ PASIVO (2.x)**

### **2.1 Pasivo Corriente**

* 2.1.1 Proveedores  
* 2.1.2 Documentos a Pagar  
* 2.1.3 Remuneraciones a Pagar  
* 2.1.4 Cargas Sociales a Pagar  
* 2.1.5 IVA Débito Fiscal  
* 2.1.6 Impuestos a Pagar  
* 2.1.7 Anticipos de Clientes

### **2.2 Pasivo No Corriente**

* 2.2.1 Préstamos Bancarios  
* 2.2.2 Deudas a Largo Plazo

---

## **🧱 3️⃣ PATRIMONIO NETO (3.x)**

* 3.1 Capital Social  
* 3.2 Ajustes al Patrimonio  
* 3.3 Resultados Acumulados  
* 3.4 Resultado del Ejercicio

---

## **🧱 4️⃣ RESULTADOS POSITIVOS (4.x)**

### **4.1 Ingresos Operativos**

* 4.1.1 Ventas  
* 4.1.2 Servicios Prestados

### **4.2 Ingresos No Operativos**

* 4.2.1 Intereses Ganados  
* 4.2.2 Diferencias de Cambio

---

## **🧱 5️⃣ RESULTADOS NEGATIVOS (5.x)**

### **5.1 Costos**

* 5.1.1 Costo de Mercaderías Vendidas  
* 5.1.2 Costo de Servicios Prestados

### **5.2 Gastos Operativos**

* 5.2.1 Sueldos y Jornales  
* 5.2.2 Cargas Sociales  
* 5.2.3 Alquileres  
* 5.2.4 Servicios  
* 5.2.5 Mantenimiento  
* 5.2.6 Honorarios  
* 5.2.7 Impuestos y Tasas  
* 5.2.8 Gastos Bancarios

### **5.3 Gastos No Operativos**

* 5.3.1 Intereses Perdidos  
* 5.3.2 Diferencias de Cambio

---

## **🧱 CODIFICACIÓN DE CUENTAS**

### **Reglas**

* Código numérico jerárquico (`1.1.4`, `5.2.3`)  
* El código **no define lógica**, solo orden  
* El tipo de cuenta define comportamiento:  
  * ACTIVO / PASIVO / PATRIMONIO / RESULTADO+

---

## **🧱 ESTADOS DE CUENTAS**

* `active`  
* `archived`

### **Reglas duras**

* Una cuenta **archivada**:  
  * no admite nuevos asientos  
  * conserva historial  
* Una cuenta **usada**:  
  * no cambia de tipo  
  * no cambia de jerarquía padre

---

## **🧱 RELACIÓN CON EL ERP (FASE 2\)**

Las cuentas **NO se usan directamente desde el ERP**.

El ERP genera **eventos** como:

* `invoice_issued`  
* `receipt_completed`  
* `payment_completed`  
* `job_completed`

ACCCORE traduce esos eventos a asientos usando **reglas contables** (PASO 3.3).

---

## **🧾 EJEMPLO CONCEPTUAL (SIN CÓDIGO)**

Evento:

invoice\_issued

Asiento:

Debe: 1.1.4 Créditos por Ventas  
Haber: 4.1.1 Ventas  
Haber: 2.1.5 IVA Débito Fiscal

⚠️ Esto es **ejemplo conceptual**, no implementación.

---

## **🔐 AUTORIZACIÓN**

* Solo `accounting_operator` y `accounting_admin`  
* Cierre y reapertura:  
  * solo `owner`  
* Admin / Member / Viewer:  
  * ❌ sin acceso

---

## **🚨 COSAS QUE NO SE HACEN**

* ❌ Borrar cuentas  
* ❌ Editar tipo de cuenta usada  
* ❌ Postear manualmente sin evento  
* ❌ Mezclar impuestos con ingresos  
* ❌ Crear cuentas “hardcodeadas” por UI

---

---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **PASO 3.3 — MOTOR DE ASIENTOS CONTABLES (EVENT → JOURNAL)**

**Contrato de arquitectura — Sin código**

---

## **🎯 OBJETIVO**

Definir el **Motor de Asientos Contables**, responsable de:

* transformar **eventos del ERP** en **asientos contables**  
* garantizar **integridad**, **idempotencia** y **trazabilidad**  
* impedir creación manual o implícita de asientos  
* asegurar cumplimiento legal y contable

Este motor es el **corazón de ACCCORE**.

---

## **🧱 PRINCIPIOS NO NEGOCIABLES**

1. **Los asientos nacen SOLO de eventos ERP**  
2. **Cada evento se procesa una sola vez**  
3. **Debe \= Haber siempre**  
4. **Nada se edita, todo se deriva**  
5. **El pasado no se corrige**  
6. **Toda traducción es auditable**

---

## **🧱 ENTRADA DEL MOTOR**

### **Eventos válidos**

* `invoice_issued`  
* `invoice_voided`  
* `receipt_completed`  
* `receipt_reversed`  
* `payment_completed`  
* `payment_reversed`  
* `job_completed`  
* `adjustment_event` (siempre explícito)

### **Reglas**

* Evento **cerrado**  
* Evento **válido**  
* Evento **no procesado**  
* Evento **pertenece a empresa activa**

Si falla alguna → **RECHAZO \+ AUDITORÍA**

---

## **🧱 SALIDA DEL MOTOR**

* 0, 1 o N **JournalEntry**  
* Cada JournalEntry tiene:  
  * fecha contable  
  * periodo contable  
  * referencia al evento  
  * estado `posted`

---

## **🧱 ESTRUCTURA DE ASIENTO**

### **JournalEntry**

* empresa  
* periodo  
* evento origen  
* timestamp de contabilización  
* estado

### **JournalLine**

* cuenta  
* debe / haber  
* importe  
* moneda  
* metadata mínima

---

## **🧱 IDempotencia (CRÍTICO)**

### **Regla**

Un evento ERP **no puede generar asientos dos veces**.

### **Mecanismo conceptual**

* Cada evento tiene:  
  * `accounting_processed = false`  
* El motor:  
  * marca el evento al procesar  
  * rechaza reprocesos

### **Reprocesamiento**

* Solo mediante comando explícito  
* Evento auditado  
* Nunca automático

---

## **🧱 SELECCIÓN DE PERIODO CONTABLE**

### **Regla base**

* El asiento se imputa al periodo:  
  * correspondiente a la **fecha del evento**  
* Si el periodo está cerrado:  
  * evento se rechaza  
  * o se difiere (según política futura)

⚠️ MVP: **rechazo duro**

---

## **🧱 REGLAS DE TRADUCCIÓN (EJEMPLOS CONCEPTUALES)**

### **📄 `invoice_issued`**

Debe: Créditos por Ventas  
Haber: Ventas  
Haber: IVA Débito Fiscal

---

### **💰 `receipt_completed`**

Debe: Caja / Bancos  
Haber: Créditos por Ventas

---

### **💸 `payment_completed`**

Debe: Proveedores  
Haber: Caja / Bancos

---

### **🔁 Reversiones (`*_reversed`)**

**Nunca se borra el asiento original**

Se genera un **asiento espejo**:

* Debe ↔ Haber  
* Mismo importe  
* Referencia al evento de reversión

---

## **🧱 VALIDACIONES CONTABLES**

Antes de postear:

* Debe \= Haber  
* Cuentas activas  
* Periodo abierto  
* Evento válido  
* Empresa coincide  
* Moneda válida

Si falla → **NO POSTEAR**

---

## **🧾 AUDITORÍA CONTABLE**

Registrar:

* evento ERP  
* asientos generados  
* líneas  
* cuentas  
* periodo  
* usuario (si aplica)  
* timestamp

---

## **🧱 ERRORES Y RECHAZOS**

Un rechazo:

* NO se corrige  
* NO se reintenta automáticamente  
* genera evento `accounting_rejected`

Motivos:

* periodo cerrado  
* evento inválido  
* inconsistencia contable

---

## **🚨 COSAS PROHIBIDAS**

* ❌ Crear asientos manuales  
* ❌ Editar asientos  
* ❌ Borrar asientos  
* ❌ Postear en periodos cerrados  
* ❌ Reprocesar sin auditoría  
* ❌ Generar asientos desde UI

---

## **🔐 AUTORIZACIÓN**

* Posteo automático: sistema  
* Reprocesos:  
  * solo `accounting_admin`  
* Cierre de periodo:  
  * solo `owner`

---

## **✅ RESULTADO DEL PASO 3.3**

Al finalizar este paso:

* tenés un motor determinístico  
* eventos → asientos trazables  
* contabilidad inmutable  
* sistema audit-ready  
* base sólida para fiscalidad

---

---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **PASO 3.4 — PERIODOS CONTABLES Y CIERRES**

**Contrato de arquitectura contable — Sin código**

---

## **🎯 OBJETIVO**

Definir el **modelo de periodos contables** y el **proceso de cierre**, garantizando que:

* la contabilidad sea **inmutable**  
* el pasado **no se reescriba**  
* los asientos queden **legalmente protegidos**  
* los errores se corrijan **hacia adelante**  
* exista **trazabilidad completa**

Este paso convierte a ACCCORE en un sistema **legalmente serio**.

---

## **🧱 PRINCIPIO MADRE**

**UN PERIODO CERRADO ES INVIOLABLE**

No admite:

* nuevos asientos  
* modificaciones  
* reversiones directas

Cualquier corrección ocurre **en periodos futuros**.

---

## **🧱 DEFINICIÓN DE PERIODO CONTABLE**

Un **Accounting Period** representa un intervalo temporal cerrado.

### **Propiedades conceptuales**

* empresa  
* fecha\_inicio  
* fecha\_fin  
* estado  
* timestamp de cierre (si aplica)

### **Estados posibles**

* `open`  
* `closed`  
* `reopened` (estado técnico, no operativo)

---

## **🧱 GRANULARIDAD**

### **MVP**

* Periodos **mensuales**  
* Año contable \= agrupación de periodos

⚠️ No se permite:

* periodos diarios  
* periodos arbitrarios  
* periodos solapados

---

## **🧱 REGLAS DE ASIGNACIÓN DE ASIENTOS**

* Cada asiento pertenece a **un solo periodo**  
* El periodo se determina por:  
  * fecha del evento ERP  
* No se reasigna un asiento a otro periodo

Si el periodo correspondiente está cerrado:

* el evento **se rechaza** (MVP)  
* se audita el rechazo

---

## **🧱 PROCESO DE CIERRE CONTABLE**

### **Secuencia obligatoria**

1. Verificar que el periodo esté `open`  
2. Validar integridad contable  
3. Verificar Debe \= Haber global  
4. Confirmar ausencia de asientos pendientes  
5. Ejecutar cierre  
6. Cambiar estado a `closed`  
7. Emitir evento `period_closed`  
8. Bloquear escrituras

---

## **🧱 VALIDACIONES PRE-CIERRE**

Antes de cerrar:

* No hay asientos desbalanceados  
* No hay eventos ERP sin procesar  
* Todas las cuentas son válidas  
* No hay inconsistencias monetarias  
* Auditoría completa

Si falla alguna → **NO cerrar**

---

## **🧱 EFECTOS DEL CIERRE**

Un periodo cerrado:

* ❌ no acepta nuevos asientos  
* ❌ no admite modificaciones  
* ❌ no permite reversiones  
* ❌ no permite reprocesos  
* ✅ conserva trazabilidad total

---

## **🧱 REAPERTURA DE PERIODO (EXCEPCIONAL)**

### **Regla dura**

**Reabrir un periodo es una excepción grave**

### **Autorización**

* Solo `owner`  
* Nunca `admin`  
* Nunca automática

---

### **Proceso de reapertura**

1. Solicitud explícita  
2. Motivo obligatorio  
3. Auditoría reforzada  
4. Cambio temporal a `reopened`  
5. Acciones estrictamente necesarias  
6. Nuevo cierre inmediato  
7. Evento `period_reopened`

⚠️ La reapertura **no borra historia**, solo habilita acciones controladas.

---

## **🧱 AJUSTES POST-CIERRE**

### **Regla**

Los errores detectados **después del cierre**:

* NO modifican el periodo cerrado  
* generan **asientos de ajuste** en el periodo actual

Ejemplos:

* ajustes contables  
* diferencias  
* reclasificaciones

---

## **🧾 AUDITORÍA CONTABLE**

Debe registrarse:

* cierre de periodo  
* reapertura  
* usuario responsable  
* timestamp  
* motivo  
* impactos derivados

La auditoría es **append-only**.

---

## **🔐 AUTORIZACIÓN**

* Cerrar periodo:  
  * `owner`  
* Reabrir periodo:  
  * `owner`  
* Postear asientos:  
  * sistema (motor)  
* Admin / Member / Viewer:  
  * ❌ sin acceso

---

## **🚨 COSAS PROHIBIDAS**

* ❌ Cerrar periodos automáticamente  
* ❌ Reabrir sin auditoría  
* ❌ Editar asientos post-cierre  
* ❌ Borrar periodos  
* ❌ Saltar validaciones  
* ❌ Corregir el pasado

---

---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **PASO 3.5 — MAYOR CONTABLE Y DERIVACIONES**

**Contrato de arquitectura contable — Sin código**

---

## **🎯 OBJETIVO**

Definir el **Mayor Contable** como estructura derivada que:

* consolida los asientos  
* permite informes financieros  
* mantiene trazabilidad completa  
* no introduce mutabilidad  
* puede recalcularse sin pérdida de información

El mayor **NO es fuente de verdad**, es **resultado**.

---

## **🧱 PRINCIPIO FUNDAMENTAL**

**LA FUENTE DE VERDAD SON LOS ASIENTOS, NO EL MAYOR**

Si el mayor y los asientos difieren,  
**los asientos ganan siempre**.

---

## **🧱 DEFINICIÓN DE MAYOR CONTABLE**

El **General Ledger (Mayor)** representa:

* acumulación de movimientos por cuenta  
* ordenados por periodo  
* con saldos progresivos

  ### **Entidades conceptuales**

* LedgerAccount (vista por cuenta)  
* LedgerPeriod (vista por periodo)  
* LedgerBalance (saldo acumulado)

⚠️ Son **estructuras derivadas**, no editables.

---

## **🧱 CONSTRUCCIÓN DEL MAYOR**

### **Fuente**

* JournalEntry  
* JournalLine  
* Account  
* AccountingPeriod

  ### **Proceso conceptual**

1. Seleccionar asientos posteados  
2. Agrupar por cuenta  
3. Ordenar cronológicamente  
4. Calcular saldos  
5. Persistir o materializar  
   ---

   ## **🧱 TIPOS DE MAYOR**

   ### **1️⃣ Mayor por Cuenta**

* Movimientos detallados  
* Saldo acumulado  
* Base para auditoría  
  ---

  ### **2️⃣ Mayor por Periodo**

* Movimientos del periodo  
* Saldo inicial  
* Saldo final  
  ---

  ### **3️⃣ Mayor Histórico**

* Arrastre inter-periodo  
* Base para balances anuales  
  ---

  ## **🧱 REGLAS DE SALDO**

* Activo:  
  * Debe incrementa  
  * Haber decrementa  
* Pasivo / Patrimonio:  
  * Haber incrementa  
  * Debe decrementa  
* Resultados:  
  * Se acumulan por periodo

Las reglas dependen del **tipo de cuenta**, no del evento.

---

## **🧱 RECÁLCULO DEL MAYOR**

### **Cuándo recalcular**

* reprocesamiento autorizado  
* reapertura de periodo  
* corrección de asientos futuros  
* inconsistencia detectada

  ### **Regla**

* El recálculo:  
  * no modifica asientos  
  * no borra historia  
  * es idempotente

  ---

  ## **🧱 RELACIÓN CON CIERRES**

* Periodos cerrados:  
  * mayor queda congelado  
* Periodos abiertos:  
  * mayor puede recalcularse

  ---

  ## **🧱 INFORMES DERIVADOS (NO MVP)**

El mayor alimenta:

* Balance General  
* Estado de Resultados  
* Libros legales

⚠️ No se implementan antes del cierre total del núcleo.

---

## **🧾 TRAZABILIDAD TOTAL**

Cada saldo debe poder rastrearse:

* Saldo → Cuenta → Línea → Asiento → Evento ERP


Si no se puede trazar, el dato es inválido.

---

## **🧱 AUTORIZACIÓN**

* Visualización:  
  * `accounting_operator`  
  * `accounting_admin`  
* Recalculo:  
  * sistema  
* Admin / Member / Viewer:  
  * ❌ sin acceso

  ---

  ## **🚨 COSAS PROHIBIDAS**

* ❌ Editar el mayor manualmente  
* ❌ Usar el mayor como input  
* ❌ Ajustar saldos sin asiento  
* ❌ Ocultar movimientos  
* ❌ Calcular balances desde ERP  
  ---

