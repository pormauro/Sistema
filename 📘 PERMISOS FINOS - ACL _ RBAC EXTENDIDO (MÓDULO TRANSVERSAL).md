# **📘 PERMISOS FINOS — ACL / RBAC EXTENDIDO (MÓDULO TRANSVERSAL)**

**Contrato de Arquitectura — Sin implementación — Sin código**

---

## **🎯 PROPÓSITO DEL MÓDULO**

Este módulo define **qué puede hacer cada usuario** dentro del sistema, de forma:

* granular

* auditable

* reproducible

* independiente del negocio

* independiente de la contabilidad

Los permisos finos **NO forman parte del Core**, **NO pertenecen al ERP**, y **NO son contabilidad**.

Son una **capa transversal**, apoyada sobre el Core.

---

## **🧱 POSICIÓN EN LA ARQUITECTURA**

`1) Core Platform`  
`2) Permisos Finos (ACL / RBAC)`  
`3) ERP Operativo`  
`4) Contabilidad (ACCCORE)`

### **Dependencias**

* Depende de: Core Platform

* NO depende de: ERP, Contabilidad

* Es requerido por: ERP y Contabilidad

---

## **🧱 PRINCIPIOS INMUTABLES**

### **1️⃣ Separación total de responsabilidades**

* Core → identidad y pertenencia

* Permisos Finos → autorización

* ERP → lógica operativa

* Contabilidad → interpretación financiera

Nunca se mezclan.

---

### **2️⃣ Permisos explícitos**

Si una acción no tiene permiso explícito:

* está prohibida

* no se infiere

* no se hereda implícitamente

---

### **3️⃣ Evaluación determinística**

Dado:

* usuario

* empresa

* acción

👉 el resultado de autorización es **siempre el mismo**.

---

### **4️⃣ Auditoría obligatoria**

Toda decisión relevante de autorización:

* puede auditarse

* puede reproducirse

* puede explicarse

---

## **🧱 COMPONENTES DEL MÓDULO**

---

### **🔹 1\) PERMISSIONS (Permisos atómicos)**

Un permiso representa **una acción concreta** del sistema.

Ejemplos:

* `jobs.view`

* `jobs.create`

* `jobs.update`

* `jobs.complete`

* `jobs.cancel`

* `invoices.issue`

* `invoices.void`

* `receipts.complete`

* `payments.execute`

* `accounting.view_reports`

* `accounting.post_entries`

* `settings.manage`

* `users.invite`

#### **Reglas**

* Son atómicos

* No dependen del rol

* No dependen de la UI

* No contienen lógica

---

### **🔹 2\) PERMISSION GROUPS (opcional)**

Agrupan permisos por dominio funcional:

* Jobs

* Sales

* Purchases

* Invoices

* Accounting

* Configuration

* Security

Solo sirven para organización y UI.

---

### **🔹 3\) ROLES FINOS (RBAC EXTENDIDO)**

Un rol fino es **un conjunto de permisos**, no una jerarquía.

Ejemplos:

* `erp_operator`

* `erp_manager`

* `finance_viewer`

* `finance_operator`

* `accounting_admin`

* `company_admin_extended`

#### **Reglas**

* Un rol **no hereda** de otro

* Los permisos se asignan explícitamente

* Un rol puede cambiar sin afectar al Core

---

### **🔹 4\) ASIGNACIÓN DE ROLES FINOS POR EMPRESA**

Los roles finos se asignan **por empresa**, no globalmente.

Un mismo usuario puede ser:

---

## **🧩 TABLA ACTUALIZADA — ROLES/PERMISOS (ACL/RBAC)**

> Consolidación de políticas de autorización aplicables a permisos finos.

| Regla | Descripción |
|---|---|
| Roles gruesos **no otorgan** permisos finos | El rol grueso solo limita el universo posible. |
| Hard‑deny por rol grueso | Si el rol grueso prohíbe, **DENY** aunque haya rol fino. |
| Permiso explícito requerido | Si no existe permiso atómico explícito → **DENY**. |
| Sin herencia implícita | Ningún rol fino hereda de otro. |
| Overrides explícitos | Si están definidos, prevalecen. |
| Auditoría obligatoria | Toda denegación crítica y acción de seguridad/contabilidad debe auditarse. |

---

## **✅ CHECKLIST PRE‑IMPLEMENTACIÓN (ACL/RBAC)**

- [ ] Separación de capas: ACL es transversal, no pertenece a Core/ERP/Contabilidad.
- [ ] Permisos **atómicos** y **explícitos** (si no existe → DENY).
- [ ] Sin herencia implícita entre roles finos.
- [ ] Hard‑deny por rol grueso aplicado antes de permisos finos.
- [ ] Overrides explícitos definidos y auditables.
- [ ] Auditoría obligatoria en denegaciones críticas y acciones sensibles.

---

## **🧭 REGLAS EXACTAS PARA BACKEND (POLICIES/ACL)**

1. Validar `X-Company-Id` y membership activa.
2. Evaluar **rol grueso** → aplicar hard‑deny si corresponde.
3. Evaluar **roles finos** asignados por empresa.
4. Verificar **permiso atómico explícito**.
5. Resolver **overrides explícitos** (si existen).
6. Registrar auditoría en denegaciones críticas y acciones sensibles.
7. Resultado final: **ALLOW** o **DENY** determinístico.

* `erp_manager` en Empresa A

* `finance_viewer` en Empresa B

Siempre respetando:

* membership activa

* empresa activa

---

### **🔹 5\) OVERRIDES POR USUARIO**

Además del rol fino, se permiten:

* permisos adicionales

* revocaciones puntuales

Ejemplos:

* permitir `jobs.cancel` a un usuario puntual

* negar `accounting.post_entries` aunque el rol lo tenga

Los overrides:

* son explícitos

* son auditables

* nunca implícitos

---

## **🧱 FLUJO DE EVALUACIÓN DE PERMISOS**

`1) Usuario autenticado`  
`2) Empresa activa`  
`3) Membership activa`  
`4) Rol grueso válido (Core)`  
`5) Rol fino asignado`  
`6) Overrides aplicados`  
`7) Evaluación del permiso solicitado`

Resultado:

* ALLOW

* DENY

Sin estados intermedios.

---

## **🧾 AUDITORÍA DE AUTORIZACIÓN**

Se debe poder registrar:

* usuario

* empresa

* permiso evaluado

* resultado

* motivo

* timestamp

Especialmente para:

* acciones sensibles

* denegaciones críticas

* cambios de configuración

---

## **🧱 RELACIÓN CON ROLES GRUESOS (CORE)**

Roles del Core:

* owner

* admin

* member

* viewer

### **Regla dura**

Los roles gruesos:

* **no otorgan permisos finos automáticamente**

* solo habilitan **posibilidad de asignación**

Ejemplo:

* `viewer` → nunca puede recibir permisos de escritura

* `owner` → puede recibir cualquier permiso fino

---

## **🧱 RELACIÓN CON ERP Y CONTABILIDAD**

ERP y Contabilidad:

* **consultan** permisos

* **no los definen**

* **no los modifican**

Esto permite:

* agregar módulos sin duplicar lógica

* auditar accesos

* cambiar permisos sin tocar negocio

---

## **🧱 SCOPE DEL MÓDULO**

### **Incluye**

* permisos atómicos

* roles finos

* asignación por empresa

* overrides

* auditoría

### **NO incluye**

* autenticación

* sesiones

* lógica de negocio

* contabilidad

* UI

---

## **🔒 ESTADO DEL DOCUMENTO**

* Módulo: Permisos Finos

* Tipo: Transversal

* Estado: DEFINIDO

* Modificable: solo agregando permisos nuevos

* Eliminación de permisos existentes: ❌ prohibida

---

## **✅ CONCLUSIÓN**

Este módulo:

* evita mezclar identidad con negocio

* permite escalar sin deuda

* habilita multiempresa real

* protege auditoría y trazabilidad

* es compatible con cualquier ERP o módulo futuro
