# **📘 CHECKLIST — IMPLEMENTACIÓN MÍNIMA VIABLE (MVP) POR MÓDULO**

**Contrato técnico — Control de alcance — Sin interpretación**

---

## **🧱 1️⃣ CORE PLATFORM — MVP**

Sin esto, el sistema **NO existe**.

### **🔐 Identidad & Seguridad**

* Users con estados (`pending`, `active`, `locked`, `disabled`, `deleted`)  
* Hash seguro de contraseña  
* Verificación de email  
* Recuperación de contraseña  
* Bloqueo automático por intentos fallidos  
* Bloqueo manual administrativo  
* User Security Events (login\_success / failed / lock / unlock)

### **🔑 Sesiones**

* Refresh tokens únicos  
* Revocación inmediata de sesión  
* Expiración configurable  
* Logout idempotente  
* Cambio de empresa por sesión

### **🏢 Multiempresa**

* Companies con lifecycle completo  
* Company Memberships  
* Roles gruesos (owner/admin/member/viewer)  
* Protección de último owner  
* Invitaciones por email con token

### **📁 Archivos**

* Files (repositorio universal)  
* File Links (asociación flexible)  
* Borrado lógico  
* Auditoría de upload/link/unlink

### **🧾 Auditoría**

* Audit log append-only  
* Auditoría de cambios de estado  
* Auditoría de seguridad  
* Auditoría de denegaciones críticas

### **⚙️ Instalación**

* Endpoint de instalación inicial  
* Creación de superadmin  
* Bloqueo permanente post-instalación  
* Evento `install_completed`

---

## **🔐 2️⃣ PERMISOS FINOS (ACL / RBAC) — MVP**

Controla el acceso **sin tocar negocio**.

### **Permisos**

* Registro de permisos atómicos  
* Identificador único por permiso  
* Permisos organizados por dominio

### **Roles Finos**

* Roles base definidos (erp\_operator, erp\_manager, etc.)  
* Asignación por empresa  
* Compatibilidad rol grueso ↔ rol fino  
* Validación hard-deny por rol grueso

### **Overrides**

* Overrides explícitos por usuario  
* Precedencia clara (override \> rol fino)

### **Evaluación**

* Evaluador determinístico de permisos  
* Resultado binario (ALLOW / DENY)  
* Auditoría de denegaciones críticas

---

## **📘 3️⃣ ERP OPERATIVO — MVP**

Registra hechos reales.  
NO interpreta contabilidad.

### **Jobs**

* Jobs con lifecycle completo  
* Sin fechas reales en la tabla principal  
* Job Time Entries (inicio/fin)  
* Job Checklist Items  
* Evidencia y responsables  
* Estados terminales respetados  
* Auditoría de transiciones

### **Ventas / Compras**

* Sales (draft/confirmed/cancelled)  
* Purchases (simétrico)  
* Validaciones cruzadas

### **Presupuestos**

* Quotes con estados  
* Aceptación / rechazo auditados

### **Facturación**

* Invoices (draft/issued/voided)  
* Bloqueo si hay receipts activos

### **Cobros / Pagos**

* Receipts (pending/completed/reversed)  
* Payments (simétrico)  
* Auditoría de ejecución y reversión

### **Eventos**

* Eventos operativos inmutables  
* Idempotencia garantizada  
* Eventos rechazados auditados

---

## **🧮 4️⃣ CONTABILIDAD (ACCCORE) — MVP**

Nunca se implementa antes del ERP.

### **Entrada**

* Consumo de eventos ERP  
* Validación de integridad temporal  
* Reprocesamiento seguro

### **Núcleo**

* Plan de cuentas  
* Asientos contables  
* Devengamientos básicos  
* Mayor

### **Cierres**

* Cierre de período  
* Bloqueo post-cierre  
* Reapertura solo por owner

### **Auditoría**

* Auditoría contable  
* Trazabilidad evento → asiento  
* No modificación de asientos

---

## **🧪 5️⃣ VALIDACIONES GLOBALES — MVP**

* No borrado físico en ningún módulo  
* Regla 4equim aplicada en todas las entidades  
* Estados terminales no reversibles  
* Fechas reales inmutables  
* Correcciones solo por eventos  
* Hard-deny antes de ACL  
* Owner bypass documentado

---

## **🚨 6️⃣ CRITERIOS DE “LISTO PARA PRODUCCIÓN”**

Un módulo está **listo** solo si:

* Todos los ítems del checklist están completos  
* No hay TODOs  
* No hay permisos implícitos  
* No hay lógica cruzada entre módulos  
* Auditoría completa  
* Documentación actualizada

