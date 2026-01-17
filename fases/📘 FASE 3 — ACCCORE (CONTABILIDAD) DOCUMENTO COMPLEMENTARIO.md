# **📘 FASE 3 — ACCCORE (CONTABILIDAD)** 

## **DOCUMENTO COMPLEMENTARIO — EVENTO DE APERTURA CONTABLE**

**Contrato de arquitectura — Sin código**

---

## **🎯 OBJETIVO**

Definir **cómo se inicializa la contabilidad** de una empresa en ACCCORE sin:

* editar saldos

* cargar asientos manuales arbitrarios

* romper trazabilidad

* violar inmutabilidad

👉 La contabilidad **nunca empieza “con números cargados a mano”**,  
 empieza con un **evento explícito y auditable**.

---

## **🧱 PRINCIPIO FUNDAMENTAL**

**TODO SALDO INICIAL ES EL RESULTADO DE UN EVENTO**

No existen:

* “saldos iniciales editables”

* “arranque por UI”

* “balances hardcodeados”

---

## **🧱 EVENTO `accounting_opening_event`**

### **Definición conceptual**

Evento especial que representa:

* el estado patrimonial inicial de la empresa

* el punto cero contable del sistema

* la frontera entre “histórico externo” y “contabilidad viva”

---

### **Características**

* Se ejecuta **una sola vez por empresa**

* Genera **asientos iniciales**

* Queda ligado al primer periodo contable

* Es **irreversible**

* Es **auditable**

---

## **🧱 CUÁNDO SE USA**

El evento de apertura se utiliza cuando:

* una empresa empieza a usar el sistema

* se migra desde otro sistema contable

* se desea comenzar contabilidad “desde cero”

* se hace onboarding contable formal

---

## **🧱 CUÁNDO NO SE USA**

❌ Para correcciones  
 ❌ Para ajustes  
 ❌ Para cierres  
 ❌ Para balances provisorios

Es **solo para inicio**.

---

## **🧱 CONTENIDO DEL EVENTO**

Conceptualmente incluye:

* fecha de apertura

* empresa

* periodo contable inicial

* listado de cuentas con saldo inicial

* moneda base

* referencia externa (opcional)

⚠️ El sistema **no valida origen externo**, solo consistencia interna.

---

## **🧱 GENERACIÓN DE ASIENTOS INICIALES**

El motor contable traduce el evento en:

* múltiples asientos

* uno por bloque lógico

* siempre balanceados

Ejemplo conceptual:

`Debe: Caja`  
`Debe: Bancos`  
`Debe: Créditos por Ventas`  
`Haber: Proveedores`  
`Haber: Capital Social`  
`Haber: Resultados Acumulados`

⚠️ Ejemplo ilustrativo, no implementación.

---

## **🧱 REGLAS DE VALIDACIÓN**

Antes de aceptar el evento:

* Debe \= Haber

* Cuentas válidas y activas

* Periodo abierto

* Evento no existente previamente

* Empresa activa

* Usuario autorizado

Si falla algo → **RECHAZO \+ AUDITORÍA**

---

## **🧱 RELACIÓN CON PERIODOS CONTABLES**

* El evento pertenece al **primer periodo**

* El periodo queda abierto tras la apertura

* El cierre funciona igual que cualquier otro periodo

---

## **🧱 AUDITORÍA REFORZADA**

El evento debe registrar:

* usuario responsable

* fecha/hora

* motivo

* referencia de migración (si aplica)

* asientos generados

* periodo afectado

Este evento **no puede ocultarse**.

---

## **🧱 AUTORIZACIÓN**

* Solo `owner`

* Nunca `admin`

* Nunca automática

* Nunca offline

---

## **🧱 PROHIBICIONES ABSOLUTAS**

* ❌ Ejecutar más de un evento de apertura

* ❌ Editar saldos iniciales

* ❌ Borrar el evento

* ❌ Reprocesar sin autorización

* ❌ Generar apertura implícita

---

## **🧱 CASO: EMPRESA SIN HISTÓRICO**

Si la empresa **no trae saldos**:

* Se ejecuta el evento

* Con **todas las cuentas en cero**

* Queda igualmente auditado

Esto evita “contabilidad fantasma”.

---

## **🧱 TRAZABILIDAD**

`Apertura → Asientos iniciales → Mayor → Reportes`

No hay atajos.

---

---

# **📘 DIAGRAMA VISUAL — FLUJO CONTABLE**

## **ERP → ACCCORE → MAYOR**

**Contrato de arquitectura — Sin código**

---

## **🎯 OBJETIVO**

Mostrar de forma **visual y determinística**:

* cómo nace un hecho

* cómo se transforma en contabilidad

* cómo se consolida

* dónde **NO** se puede intervenir

---

## **🧱 VISIÓN GENERAL**

`┌──────────────┐`  
`│     ERP      │`  
`│ (Hechos)     │`  
`└──────┬───────┘`  
       `│`  
       `│ Eventos operativos cerrados`  
       `▼`  
`┌────────────────────┐`  
`│     ACCCORE        │`  
`│ Motor de Asientos  │`  
`└──────┬─────────────┘`  
       `│`  
       `│ Asientos contables inmutables`  
       `▼`  
`┌────────────────────┐`  
`│   MAYOR CONTABLE   │`  
`│ (Derivado)         │`  
`└──────┬─────────────┘`  
       `│`  
       `│ Derivaciones`  
       `▼`  
`┌────────────────────┐`  
`│  REPORTES / FISCO  │`  
`│ (Fuera de MVP)     │`  
`└────────────────────┘`

---

## **🧱 NIVEL 1 — ERP (HECHOS)**

`ERP`  
`│`  
`├─ Jobs`  
`│   └─ job_completed`  
`│`  
`├─ Sales`  
`│   └─ invoice_issued`  
`│`  
`├─ Receipts`  
`│   └─ receipt_completed`  
`│`  
`├─ Payments`  
`│   └─ payment_completed`  
`│`  
`└─ Reversiones`  
    `└─ *_reversed`

### **Reglas**

* El ERP **NO sabe contabilidad**

* El ERP **NO conoce cuentas**

* El ERP **NO genera asientos**

* El ERP **solo emite eventos cerrados**

---

## **🧱 NIVEL 2 — FRONTERA ERP → ACCCORE**

`Evento ERP cerrado`  
`│`  
`├─ válido`  
`├─ no procesado`  
`├─ empresa activa`  
`└─ periodo potencialmente abierto`

Si falla algo:

`Evento → RECHAZO → Auditoría`

---

## **🧱 NIVEL 3 — ACCCORE (INTERPRETACIÓN)**

`ACCCORE`  
`│`  
`├─ Valida evento`  
`├─ Determina periodo contable`  
`├─ Aplica reglas de traducción`  
`├─ Genera JournalEntry`  
`├─ Genera JournalLines`  
`├─ Marca evento como procesado`  
`└─ Audita todo`

### **Ejemplo conceptual**

`invoice_issued`  
   `│`  
   `▼`  
`JournalEntry`  
   `├─ Debe: Créditos por Ventas`  
   `├─ Haber: Ventas`  
   `└─ Haber: IVA Débito Fiscal`

### **Reglas duras**

* Debe \= Haber

* No edición

* No borrado

* Idempotente

---

## **🧱 NIVEL 4 — PERIODOS CONTABLES**

`Periodo OPEN`  
`│`  
`├─ acepta asientos`  
`│`  
`Periodo CLOSED`  
`│`  
`└─ rechaza asientos`

Correcciones:

`Error detectado`  
`│`  
`└─ Ajuste en periodo futuro`

---

## **🧱 NIVEL 5 — MAYOR CONTABLE (DERIVADO)**

`JournalEntries`  
`│`  
`├─ agrupación por cuenta`  
`├─ orden cronológico`  
`├─ cálculo de saldos`  
`└─ consolidación por periodo`

Resultado:

`Cuenta → Movimientos → Saldo`

### **Regla clave**

El mayor **se puede recalcular**,  
 los asientos **NO**.

---

## **🧱 TRAZABILIDAD TOTAL**

`Reporte`  
  `↓`  
`Mayor`  
  `↓`  
`Cuenta`  
  `↓`  
`JournalLine`  
  `↓`  
`JournalEntry`  
  `↓`  
`Evento ERP`

Si esta cadena se rompe → **dato inválido**.

---

## **🚫 ZONAS PROHIBIDAS (EXPLÍCITO)**

`UI ─X→ Asientos`  
`UI ─X→ Mayor`  
`ERP ─X→ Mayor`  
`ERP ─X→ Contabilidad directa`  
`Mayor ─X→ ERP`

No hay excepciones.

---

## **🔐 AUTORIZACIÓN (RESUMEN)**

* ERP:

  * roles operativos

* ACCCORE:

  * solo sistema \+ roles contables

* Mayor:

  * solo lectura

* Cierres:

  * solo owner

---

---

# **📘 CHECKLIST — IMPLEMENTACIÓN CONTABLE (ACCCORE)**

**FASE 3 — Control de implementación — Sin código**

---

## **🧱 0️⃣ REGLAS BASE (GATE INICIAL)**

Si algo de este bloque falla → **NO IMPLEMENTAR CONTABILIDAD**.

* ERP implementado y estable (FASE 2 cerrada)

* Eventos ERP cerrados e inmutables

* Auditoría operativa funcionando

* No existe contabilidad en ERP

* No existe UI contable directa

---

## **🧱 1️⃣ MODELO CONTABLE BASE**

* Entidad **Account**

* Entidad **AccountingPeriod**

* Entidad **JournalEntry**

* Entidad **JournalLine**

* Relación evento ERP → asiento

* Sin borrado físico

* Sin edición de asientos

---

## **🧱 2️⃣ PLAN DE CUENTAS**

* Plan único por empresa

* Estructura jerárquica

* Tipos de cuenta definidos

* Cuentas activas / archivadas

* Bloqueo de edición en cuentas usadas

* Auditoría de cambios estructurales

---

## **🧱 3️⃣ PERIODOS CONTABLES**

* Periodos mensuales

* Sin solapamiento

* Estados (`open`, `closed`)

* Periodo único por fecha

* Validación de periodo abierto

* Auditoría de cambios de estado

---

## **🧱 4️⃣ EVENTO DE APERTURA CONTABLE**

* Evento `accounting_opening_event`

* Ejecutable una sola vez

* Genera asientos iniciales

* Debe \= Haber

* Solo `owner`

* Auditoría reforzada

---

## **🧱 5️⃣ MOTOR DE ASIENTOS**

* Listener de eventos ERP

* Validación de evento

* Idempotencia

* Traducción evento → asiento

* Asientos espejo para reversiones

* Rechazo auditado

---

## **🧱 6️⃣ VALIDACIONES CONTABLES**

Antes de postear:

* Debe \= Haber

* Cuentas activas

* Periodo abierto

* Empresa correcta

* Evento no procesado

* Moneda válida

---

## **🧱 7️⃣ CIERRES CONTABLES**

* Proceso de cierre

* Validaciones pre-cierre

* Bloqueo post-cierre

* Evento `period_closed`

* Reapertura solo `owner`

* Auditoría reforzada

---

## **🧱 8️⃣ AJUSTES POST-CIERRE**

* Ajustes solo en periodos futuros

* Evento explícito

* Sin modificación del pasado

* Auditoría

---

## **🧱 9️⃣ MAYOR CONTABLE**

* Derivado de asientos

* Recalculable

* No editable

* Por cuenta

* Por periodo

* Trazabilidad completa

---

## **🧱 🔟 TRAZABILIDAD TOTAL**

* Evento ERP → Asiento

* Asiento → Línea

* Línea → Cuenta

* Cuenta → Mayor

* Mayor → Reportes

Si algún eslabón falta → **dato inválido**.

---

## **🧱 1️⃣1️⃣ AUTORIZACIÓN**

* Roles contables definidos

* Admin sin acceso contable

* Member / Viewer sin acceso

* Owner con control total

* Denegaciones auditadas

---

## **🧱 1️⃣2️⃣ AUDITORÍA CONTABLE**

* Auditoría de asientos

* Auditoría de cierres

* Auditoría de reaperturas

* Auditoría de rechazos

* Auditoría inmutable

---

## **🚨 CRITERIOS DE BLOQUEO**

No avanzar si:

* hay asientos editables

* hay borrado físico

* hay UI contable directa

* hay lógica contable en ERP

* hay bypass de cierres

* hay corrección del pasado

---

## **✅ CRITERIO DE “CONTABILIDAD LISTA”**

La contabilidad se considera **lista** solo si:

* todos los ítems están completos

* no hay TODOs

* no hay atajos

* documentación alineada

* auditoría verificable

---

---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **DOCUMENTO COMPLEMENTARIO — EVENTO DE AJUSTE CONTABLE**

**Contrato de arquitectura — Sin código**

---

## **🎯 OBJETIVO**

Definir **cómo se corrigen errores contables** en ACCCORE sin:

* editar asientos existentes

* reabrir periodos innecesariamente

* romper trazabilidad

* violar cierres contables

👉 **Todo ajuste es un evento nuevo**, nunca una modificación del pasado.

---

## **🧱 PRINCIPIO FUNDAMENTAL**

**EL PASADO NO SE CORRIGE, SE COMPENSA**

La contabilidad avanza por eventos, no por edición.

---

## **🧱 EVENTO `accounting_adjustment_event`**

### **Definición**

Evento explícito que representa una **corrección contable controlada**, aplicada:

* en un **periodo abierto**

* sobre **errores detectados**

* sin modificar asientos originales

---

## **🧱 CUÁNDO SE USA**

* error de imputación de cuenta

* diferencia detectada post-cierre

* reclasificación contable

* ajuste por redondeo

* corrección de criterio contable

---

## **🧱 CUÁNDO NO SE USA**

❌ para corregir hechos operativos  
 ❌ para “arreglar números”  
 ❌ para anular eventos ERP  
 ❌ para modificar periodos cerrados  
 ❌ como reemplazo de reversiones

---

## **🧱 RELACIÓN CON CIERRES**

* El ajuste:

  * **nunca** se aplica en un periodo cerrado

  * siempre se registra en el **periodo actual**

* El periodo cerrado permanece intacto

---

## **🧱 CONTENIDO DEL EVENTO**

Conceptualmente incluye:

* empresa

* fecha del ajuste

* periodo contable actual

* motivo obligatorio

* referencia a asientos afectados (informativo)

* usuario responsable

---

## **🧱 GENERACIÓN DE ASIENTOS DE AJUSTE**

El motor contable traduce el evento en:

* uno o más asientos

* balanceados

* claramente identificados como **ajuste**

Ejemplo conceptual:

`Debe: Gasto mal imputado`  
`Haber: Cuenta correcta`

⚠️ El asiento original **no se toca**.

---

## **🧱 VALIDACIONES PREVIAS**

Antes de aceptar el evento:

* Periodo abierto

* Debe \= Haber

* Cuentas válidas

* Motivo presente

* Usuario autorizado

Si falla algo → **RECHAZO \+ AUDITORÍA**

---

## **🧱 AUDITORÍA REFORZADA**

Debe registrarse:

* evento de ajuste

* usuario

* fecha

* motivo

* asientos generados

* referencias históricas

Este evento **no puede ocultarse**.

---

## **🧱 AUTORIZACIÓN**

* Crear ajuste:

  * `accounting_admin`

* Ejecutar cierre posterior:

  * `owner`

Admin:

* ❌ no puede ajustar periodos cerrados

* ❌ no puede borrar ajustes

---

## **🧱 PROHIBICIONES ABSOLUTAS**

* ❌ Editar asientos originales

* ❌ Ajustar en periodos cerrados

* ❌ Usar ajustes para corregir ERP

* ❌ Omitir motivo

* ❌ Borrar eventos de ajuste

---

## **🧱 TRAZABILIDAD**

`Error → Adjustment Event → Asiento de Ajuste → Mayor`

El historial completo **queda visible**.

---

## **🧱 CASO ESPECIAL — AJUSTES MENORES**

Diferencias mínimas:

* redondeos

* centavos

* ajustes técnicos

Se permiten:

* solo mediante evento

* solo con motivo

* solo en periodo abierto

Nunca silenciosos.

---

## **✅ RESULTADO**

Con este evento:

* el sistema permite correcciones

* sin romper cierres

* sin reescribir historia

* con auditoría completa

---

---

# **📘 FASE 3 — ACCCORE (CONTABILIDAD)**

## **POLÍTICA DE MIGRACIÓN HISTÓRICA**

**Contrato de arquitectura — Sin código**

---

## **🎯 OBJETIVO**

Definir **cómo migrar información histórica** desde sistemas externos a ACCCORE sin:

* reescribir el pasado

* inventar asientos

* romper cierres

* perder trazabilidad

* mezclar contabilidad vieja con nueva

👉 La migración **delimita pasado externo vs contabilidad viva**.

---

## **🧱 PRINCIPIO FUNDAMENTAL**

**EL SISTEMA NO “IMPORTA CONTABILIDAD”,**  
 **IMPORTA UN ESTADO CONTABLE INICIAL**

ACCCORE **no reproduce** la historia completa de otros sistemas.  
 ACCCORE **arranca desde un punto cero explícito**.

---

## **🧱 ESTRATEGIAS DE MIGRACIÓN PERMITIDAS**

Solo existen **DOS** estrategias válidas.

---

## **🅰️ ESTRATEGIA A — MIGRACIÓN POR SALDOS (RECOMENDADA)**

### **Concepto**

* Se migran **saldos finales consolidados**

* No se migran asientos históricos

* El pasado queda **fuera del sistema**

---

### **Proceso**

1. Extraer balance final del sistema anterior

2. Validar consistencia externa

3. Ejecutar `accounting_opening_event`

4. Generar asientos iniciales

5. Comenzar contabilidad viva en ACCCORE

---

### **Ventajas**

* limpia

* rápida

* auditable

* sin deuda técnica

* sin contaminar el sistema

---

### **Desventajas**

* no se navega detalle histórico interno

* el pasado queda como referencia externa

---

## **🅱️ ESTRATEGIA B — MIGRACIÓN POR EVENTOS CONSOLIDADOS (EXCEPCIONAL)**

### **Concepto**

* Se migran **eventos resumidos**

* No asientos uno a uno

* Se agrupa por periodo

---

### **Reglas duras**

* Un evento por periodo

* Evento explícito de tipo:

  * `historical_adjustment_event`

* Claramente marcado como migrado

* No editable

* No reversible

---

### **Uso permitido**

* exigencia legal

* auditorías específicas

* necesidad contractual

⚠️ **No es MVP**, solo bajo justificación formal.

---

## **🧱 ESTRATEGIA PROHIBIDA (IMPORTANTE)**

❌ Importar asientos históricos uno a uno  
 ❌ Importar movimientos sin evento  
 ❌ Mezclar fechas pasadas con periodos vivos  
 ❌ Editar el pasado para “hacerlo coincidir”  
 ❌ Simular historia dentro de ACCCORE

Esto **rompe el sistema**.

---

## **🧱 EVENTO DE MIGRACIÓN**

### **Evento `accounting_opening_event`**

* Es el **único** evento válido para iniciar

* Marca el límite histórico

* Todo lo anterior es “externo”

---

### **Metadata obligatoria**

* sistema de origen

* fecha de corte

* responsable

* referencia documental

---

## **🧱 PERIODOS Y MIGRACIÓN**

* El primer periodo contable:

  * inicia después del corte

* Periodos anteriores:

  * **no existen** en ACCCORE

Esto es deliberado.

---

## **🧱 AUDITORÍA DE MIGRACIÓN**

Debe registrarse:

* evento de apertura

* origen de datos

* fecha de corte

* responsable

* cuentas y saldos

* documentos de respaldo

La auditoría **nunca se borra**.

---

## **🧱 VALIDACIONES PREVIAS A MIGRACIÓN**

Antes de ejecutar:

* Balance externo equilibrado

* Cuentas mapeadas al plan base

* IVA separado correctamente

* Periodo inicial abierto

* Autorización owner

* Documentación respaldatoria

Si falla algo → **NO migrar**

---

## **🧱 CASO: EMPRESA SIN HISTÓRICO**

* Se ejecuta evento de apertura

* Con todas las cuentas en cero

* Se audita igual

Esto evita “contabilidad fantasma”.

---

## **🧱 CONSULTA DE HISTÓRICO EXTERNO**

El sistema **puede**:

* guardar PDFs

* adjuntar balances externos

* referenciar documentos

Pero:

* ❌ no los interpreta

* ❌ no los mezcla

* ❌ no los convierte en asientos

---

## **🧱 TRAZABILIDAD**

`Sistema anterior`  
      `↓`  
`Documento externo`  
      `↓`  
`Evento de apertura`  
      `↓`  
`Asientos iniciales`  
      `↓`  
`Mayor`

No hay otra cadena válida.

---

## **🧱 AUTORIZACIÓN**

* Ejecutar migración:

  * solo `owner`

* Nunca `admin`

* Nunca automática

* Nunca offline

---

## **🚨 RIESGOS EVITADOS CON ESTA POLÍTICA**

* doble contabilidad

* balances inconsistentes

* ajustes eternos

* cierres inválidos

* auditorías fallidas

---

## **✅ RESULTADO**

Con esta política:

* la migración es segura

* el sistema queda limpio

* el pasado queda delimitado

* ACCCORE arranca fuerte

---

