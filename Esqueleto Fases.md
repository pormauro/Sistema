📐 MAPA MAESTRO DE FASES (NUMERADAS)
FASE 0 — Fundación técnica

Base mínima para que el sistema exista, arranque y sea observable.

FASE 1 — Core Platform (Identidad & Acceso)
Usuarios, empresas, membresías y permisos.

FASE 2 — Operación / ERP Base
Jobs, clientes, proveedores, archivos, trazabilidad operativa.

FASE 3 — Contabilidad Núcleo (ACCCORE)
Verdad económica inmutable, independiente del país.

FASE 4 — Fiscal / Impositiva
Impuestos, documentos legales, cumplimiento normativo.

FASE 5 — Offline / Sync / Eventos
Offline-first, colas, conflictos y sincronización segura.

FASE 6 — Analítica / Control
KPIs, costos, rentabilidad, tableros.

FASE 7 — Integraciones
APIs, bancos, fiscal, import/export.

FASE 8 — Hardening / Escala
Seguridad, performance, resiliencia, multi-tenant real.










# **🧱 FASE 0 — FUNDACIÓN TÉCNICA**

**Propósito:** que el sistema arranque, se instale, se observe y no sea frágil.

### **Incluye**

* Arquitectura de repositorios  
* Convenciones globales (nombres, UUID, timestamps)  
* Configuración de entorno (`.env`, secrets)  
* Healthcheck (API / DB / storage)  
* Manejo global de errores  
* Logging base (request, error, debug)  
* Timezone unificado  
* Moneda base del sistema  
* Soft-delete universal  
* Script de instalación  
* README técnico  
* Versionado semántico

### **No incluye**

* Usuarios  
* Empresas  
* Roles  
* Negocio  
* Contabilidad

---

# **🧠 FASE 1 — CORE PLATFORM (IDENTIDAD)**

**Propósito:** quién es quién, en qué empresa y con qué permisos.

### **Incluye**

* Users  
* Companies  
* Memberships (user ↔ company)  
* Roles gruesos  
* Permisos finos (policies)  
* Login / refresh / revoke  
* Invitaciones  
* Estados de usuario  
* Estados de empresa  
* Auditoría base  
* Historial de cambios  
* Scoping por empresa

### **No incluye**

* Clientes  
* Proveedores  
* Jobs  
* Facturas  
* Contabilidad

---

# **📁 FASE 2 — OPERACIÓN / ERP BASE**

**Propósito:** ejecutar trabajo real, con trazabilidad.

### **Incluye**

* Clientes y proveedores (referencias a companies)  
* Jobs (trabajos)  
* Estados estrictos (state machine)  
* Checklists operativos  
* Asignación de personas  
* Fechas y horarios desacoplados  
* Evidencias (fotos, docs)  
* Carpetas  
* Archivos  
* Logs operativos  
* Reglas de edición/bloqueo  
* Relaciones fuertes (FK reales)

### **No incluye**

* Asientos contables  
* Mayor  
* Impuestos  
* Facturación fiscal

---

# **🧾 FASE 3 — CONTABILIDAD NÚCLEO (ACCCORE)**

**Propósito:** verdad económica inmutable.

### **Incluye**

* Plan de cuentas  
* Asientos contables  
* Partida doble  
* Mayor general  
* Eventos contables  
* Inmutabilidad (append-only)  
* Ajustes contables  
* Cierre de períodos  
* Multi-moneda  
* Conversión histórica  
* Conciliaciones internas  
* Auditoría contable

### **No incluye**

* IVA  
* AFIP  
* Numeración legal  
* Facturas fiscales

---

# **💰 FASE 4 — FISCAL / IMPOSITIVA**

**Propósito:** cumplir con el estado sin romper el core.

### **Incluye**

* Configuración de impuestos  
* IVA / VAT / Sales Tax  
* Retenciones / percepciones  
* Regímenes fiscales  
* Documentos fiscales  
* Numeración legal  
* Fiscalización  
* Reportes oficiales  
* Multi-jurisdicción  
* Exportación fiscal

### **No incluye**

* Lógica contable base  
* Cambios en el mayor

---

# **🔄 FASE 5 — OFFLINE / SYNC**

**Propósito:** funcionar sin conexión y sincronizar sin mentir.

### **Incluye**

* Definición de scope offline  
* Cola de eventos  
* Sync batch  
* Versionado de registros  
* Conflictos  
* Resolución de conflictos  
* Locks lógicos  
* Reintentos  
* Auditoría de sync  
* Dispositivos  
* Identidad de cliente

### **No incluye**

* Nuevas reglas de negocio  
* Cambios contables

---

# **📊 FASE 6 — ANALÍTICA / CONTROL**

**Propósito:** entender el negocio y decidir.

### **Incluye**

* KPIs operativos  
* KPIs financieros  
* Costos reales  
* Rentabilidad por job  
* Dashboards  
* Alertas  
* Proyecciones  
* Exportaciones  
* Históricos consolidados

### **No incluye**

* Operaciones  
* Escritura de datos core

---

# **🔌 FASE 7 — INTEGRACIONES**

**Propósito:** interoperar sin contaminar el sistema.

### **Incluye**

* APIs públicas  
* Webhooks  
* Integraciones bancarias  
* Integraciones fiscales  
* Importadores  
* Exportadores  
* ETL  
* Permisos por API  
* Rate limiting  
* Logs de integración

### **No incluye**

* Lógica core  
* Reglas contables internas

---

# **🔐 FASE 8 — HARDENING / ESCALA**

**Propósito:** sobrevivir al mundo real.

### **Incluye**

* Seguridad avanzada  
* Encriptación  
* Backups  
* Restore  
* Disaster recovery  
* Escalabilidad  
* Performance  
* Observabilidad avanzada  
* Multi-tenant isolation  
* Cumplimiento

---

