# **📘 POLÍTICAS DE AUTORIZACIÓN POR ROL GRUESO (CORE ROLES)**

**Contrato de Arquitectura — Sin código — Sin implementación**

---

## **🎯 PROPÓSITO**

Este documento define **qué está permitido y qué está prohibido** para cada **rol grueso** del Core:

* `owner`  
* `admin`  
* `member`  
* `viewer`

Los roles gruesos **NO otorgan permisos finos directamente**.  
Definen **límites máximos**, **restricciones duras** y **capacidades de asignación**.

---

## **🧱 PRINCIPIOS INMUTABLES**

1. Los roles gruesos **no ejecutan acciones**  
2. Los roles gruesos **limitan el universo de permisos finos posibles**  
3. Ningún rol fino puede violar la política del rol grueso  
4. El Core **no conoce permisos finos**, solo políticas  
5. Toda violación → **DENY** \+ evento auditable

---

## **🧭 CAPAS DE DECISIÓN**

Rol Grueso (Core)  
        ↓ limita  
Roles Finos (ACL)  
        ↓ combinan  
Permisos Atómicos

Si una acción no está permitida por el **rol grueso**,  
**no importa** qué rol fino tenga el usuario → **DENY**.

---

## **👑 ROL: OWNER**

### **🎯 Propósito**

Control total de la empresa.  
Responsable legal y operativo.

---

### **✅ Puede**

* Asignar **cualquier rol fino**  
* Ejecutar **cualquier permiso fino**  
* Administrar usuarios y memberships  
* Modificar configuración de empresa  
* Acceder a ERP completo  
* Acceder a contabilidad completa  
* Cerrar y reabrir períodos contables  
* Ver y exportar auditoría  
* Delegar permisos  
* Transferir ownership

---

### **❌ No puede**

* Eliminar físicamente datos  
* Eliminar auditoría  
* Romper regla 4equim  
* Dejar la empresa sin owner

---

### **🔒 Restricciones duras**

* Siempre debe existir **al menos un owner**  
* Todas las acciones críticas son auditadas

---

## **🛠 ROL: ADMIN**

### **🎯 Propósito**

Gestión operativa y administrativa de la empresa.

---

### **✅ Puede**

* Asignar **roles finos no críticos**  
* Operar ERP completo  
* Gestionar jobs, ventas, compras  
* Emitir invoices  
* Gestionar cobros y pagos  
* Ver reportes operativos  
* Ver auditoría (solo lectura)

---

### **❌ No puede**

* Asignar permisos contables críticos  
* Cerrar o reabrir períodos contables  
* Modificar reglas contables  
* Eliminar owners  
* Transferir ownership  
* Cambiar políticas de autorización

---

### **🔒 Restricciones duras**

* No puede auto-elevarse a owner  
* No puede modificar políticas de rol grueso

---

## **👷 ROL: MEMBER**

### **🎯 Propósito**

Ejecución operativa.

---

### **✅ Puede**

* Ejecutar acciones **solo si tiene rol fino compatible**  
* Operar jobs  
* Registrar tiempos  
* Crear operaciones borrador  
* Subir y asociar archivos  
* Ver información operativa propia

---

### **❌ No puede**

* Asignar roles (finos o gruesos)  
* Cancelar operaciones críticas  
* Emitir invoices  
* Confirmar ventas/compras  
* Acceder a contabilidad  
* Ver auditoría  
* Cambiar configuración de empresa

---

### **🔒 Restricciones duras**

* Nunca puede recibir permisos contables  
* Nunca puede administrar usuarios

---

## **👀 ROL: VIEWER**

### **🎯 Propósito**

Lectura y observación.

---

### **✅ Puede**

* Ver información permitida  
* Ver jobs, ventas, invoices (read-only)  
* Ver reportes operativos básicos

---

### **❌ No puede**

* Crear, modificar o cancelar nada  
* Registrar tiempos  
* Subir archivos  
* Ver contabilidad  
* Ver auditoría  
* Gestionar usuarios  
* Ejecutar acciones

---

### **🔒 Restricciones duras**

* Todos los permisos deben ser `.view`  
* Cualquier permiso de escritura → DENY

---

## **🧱 MATRIZ RESUMEN**

┌────────┬──────────┬──────────┬──────────┐  
│ Acción │ Owner    │ Admin    │ Member   │ Viewer   │  
├────────┼──────────┼──────────┼──────────┤  
│ ERP    │ FULL     │ FULL     │ LIMITADO │ READ     │  
│ ACL    │ FULL     │ PARCIAL  │ NO       │ NO       │  
│ Contab │ FULL     │ NO       │ NO       │ NO       │  
│ Audit  │ FULL     │ READ     │ NO       │ NO       │  
│ Config │ FULL     │ LIMITED  │ NO       │ NO       │  
└────────┴──────────┴──────────┴──────────┘

---

## **🧾 AUDITORÍA DE POLÍTICAS**

Debe auditarse:

* asignación de rol grueso  
* asignación de rol fino  
* cambios de roles  
* intentos bloqueados por política  
* intentos de elevación indebida

---

## **🔒 REGLAS FINALES**

* Los roles gruesos **nunca cambian dinámicamente**  
* Los permisos finos **nunca rompen políticas**  
* Toda evaluación es determinística  
* Toda denegación crítica es auditable  
* No hay excepciones implícitas

---

## **✅ CONCLUSIÓN**

Con estas políticas:

* El Core mantiene el control  
* ACL es flexible pero segura  
* ERP no conoce seguridad  
* Contabilidad queda protegida  
* El sistema es escalable  
* No hay escalamiento indebido  
* No hay deuda conceptual

