

# **📘 CORE PLATFORM** 

**Modelo \+ Reglas \+ Entidades \+ Ciclos de vida \+ Seguridad \+ Auditoría \+ Instalación inicial**  
**Sin ambigüedades • Sin código • Sin implementación • Solo contrato de arquitectura**

---

# **🧱 0\) PRINCIPIOS INMUTABLES**

## **0.1 — NO EXISTE EL BORRADO FÍSICO**

Todo dato crítico **nunca se elimina físicamente**, solo cambia de estado:  
`active`, `inactive`, `archived`, `deleted`.

Toda tabla core debe tener:

* `status`  
* `deleted_at`  
* `created_at`  
* `updated_at`

## **0.2 — REGLA PADRE–HIJO (4EQUIM)**

Un registro **NO puede eliminarse** si tiene:

* hijos activos  
* contenido asociado  
* dependencias lógicas activas

Opciones permitidas:

1. eliminar primero los hijos  
2. operación explícita “eliminar todo el contenido”  
3. rechazar la operación

## **0.3 — AUDITORÍA UNIVERSAL**

Todo cambio relevante → audit\_log  
Nunca se modifica  
Nunca se elimina  
Append-only

## **0.4 — INSTALACIÓN INICIAL**

Antes de estar instalado:

* `APP_INSTALLED = false`  
* Primer usuario creado → `superadmin`  
* Luego el endpoint queda bloqueado permanentemente

## **0.5 — MULTIEMPRESA REAL**

Todo dato operativo requiere `company_id` (cuando corresponde).  
Una sesión siempre está asociada a un contexto de empresa activa.

---

# **🗂 ENTIDADES UNIFICADAS (POST-FUSIÓN)**

**Estas son las tablas DEFINITIVAS**.  
Si no aparece acá, NO forma parte del Core.

Voy a fusionar donde corresponde para mayor coherencia, simplicidad y potencia.

---

# **1️⃣ USERS (usuarios del sistema)**

## **Propósito**

Identidad digital global. Sin empresa asociada. Nunca se borra físicamente.

## **Estados**

`pending`, `active`, `locked`, `disabled`, `deleted`

## **Tabla final (completa)**

Incluye **los campos más completos y seguros** de todas las versiones previas.

users (  
  id CHAR(36) PRIMARY KEY,  
  email VARCHAR(255) NOT NULL UNIQUE,  
  password\_hash VARCHAR(255) NOT NULL,

  status ENUM('pending','active','locked','disabled','deleted') NOT NULL DEFAULT 'pending',  
  locked\_until DATETIME(6) NULL,  
  email\_verified\_at DATETIME(6) NULL,  
  deleted\_at DATETIME(6) NULL,

  created\_at DATETIME(6) NOT NULL,  
  updated\_at DATETIME(6) NOT NULL  
)

---

# **2️⃣ USER\_SECURITY\_EVENTS (FUSIÓN: login\_attempts \+ seguridad de acceso)**

💡 En vez de dos tablas separadas, lo fusionamos en una estructura de **eventos de seguridad universal**, más poderosa, más auditable y más escalable.

Esto permite registrar:

* login attempts  
* bloqueos automáticos  
* desbloqueos  
* resets  
* captchas  
* eventos de credenciales

## **Tabla final**

user\_security\_events (  
  id CHAR(36) PRIMARY KEY,  
  user\_id CHAR(36) NULL,  
  email VARCHAR(255) NOT NULL,  
  ip\_address VARCHAR(100),  
  user\_agent VARCHAR(500),

  event\_type ENUM(  
    'login\_success',  
    'login\_failed',  
    'password\_reset\_requested',  
    'password\_reset\_used',  
    'email\_verification\_sent',  
    'email\_verified',  
    'auto\_lock',  
    'auto\_unlock',  
    'manual\_lock',  
    'manual\_unlock'  
  ) NOT NULL,

  metadata JSON,  
  created\_at DATETIME(6) NOT NULL,

  INDEX (email),  
  INDEX (user\_id),  
  INDEX (event\_type),  
  INDEX (created\_at)  
)

## **Beneficios**

* sustituye login\_attempts  
* registra todos los eventos de seguridad  
* análisis avanzado de ataques  
* lista para machine learning / anomaly detection

---

# **3️⃣ USER\_ROLES (roles globales)**

user\_roles (  
  id CHAR(36) PRIMARY KEY,  
  user\_id CHAR(36) NOT NULL,  
  role ENUM('superadmin','system') NOT NULL,  
  status ENUM('active','deleted') NOT NULL DEFAULT 'active',  
  deleted\_at DATETIME(6),  
  created\_at DATETIME(6),  
  updated\_at DATETIME(6)  
)

---

# **4️⃣ USER\_SESSIONS (sesiones del usuario)**

## **Mejorada (fusión de variantes)**

Incluye usuario, empresa activa y seguridad adicional.

user\_sessions (  
  id CHAR(36) PRIMARY KEY,  
  user\_id CHAR(36) NOT NULL,  
  active\_company\_id CHAR(36) NULL,

  refresh\_token VARCHAR(255) NOT NULL UNIQUE,  
  ip\_address VARCHAR(100),  
  user\_agent VARCHAR(500),

  expires\_at DATETIME(6) NOT NULL,  
  revoked\_at DATETIME(6) NULL,  
  created\_at DATETIME(6) NOT NULL,  
  updated\_at DATETIME(6) NOT NULL  
)

---

# **5️⃣ COMPANIES (empresas / tenants)**

Combinando todas las versiones:

companies (  
  id CHAR(36) PRIMARY KEY,  
  legal\_name VARCHAR(255) NOT NULL,  
  trade\_name VARCHAR(255),  
  tax\_id VARCHAR(50),

  status ENUM('active','inactive','archived','deleted') NOT NULL DEFAULT 'active',  
  deleted\_at DATETIME(6),

  created\_at DATETIME(6) NOT NULL,  
  updated\_at DATETIME(6) NOT NULL  
)

Reglas duras:

* no se puede eliminar si tiene owners  
* no se puede eliminar si tiene datos activos  
* no puede quedar sin owner

---

# **6️⃣ COMPANY\_INVITATIONS (invitaciones, versión final)**

company\_invitations (  
  id CHAR(36) PRIMARY KEY,  
  company\_id CHAR(36) NOT NULL,  
  email VARCHAR(255) NOT NULL,  
  role ENUM('owner','admin','member','viewer') NOT NULL,  
  token CHAR(36) NOT NULL,

  status ENUM('pending','accepted','rejected','expired','revoked') NOT NULL,  
  expires\_at DATETIME(6),  
  accepted\_at DATETIME(6),

  created\_at DATETIME(6) NOT NULL,  
  updated\_at DATETIME(6) NOT NULL  
)

---

# **7️⃣ COMPANY\_MEMBERSHIPS (participación)**

company\_memberships (  
  id CHAR(36) PRIMARY KEY,  
  company\_id CHAR(36) NOT NULL,  
  user\_id CHAR(36) NOT NULL,  
  status ENUM('active','invited','revoked','left','deleted') NOT NULL,  
  deleted\_at DATETIME(6),

  created\_at DATETIME(6),  
  updated\_at DATETIME(6)  
)

---

# **8️⃣ MEMBERSHIP\_ROLES (roles dentro de empresa)**

membership\_roles (  
  id CHAR(36) PRIMARY KEY,  
  membership\_id CHAR(36) NOT NULL,  
  role ENUM('owner','admin','member','viewer') NOT NULL,  
  status ENUM('active','deleted') NOT NULL DEFAULT 'active',  
  deleted\_at DATETIME(6),

  created\_at DATETIME(6),  
  updated\_at DATETIME(6)  
)

---

# **9️⃣ COMPANY\_SETTINGS (config por empresa)**

company\_settings (  
  id CHAR(36) PRIMARY KEY,  
  company\_id CHAR(36) NOT NULL,  
  setting\_key VARCHAR(100) NOT NULL,  
  setting\_value TEXT,  
  status ENUM('active','deleted') NOT NULL DEFAULT 'active',  
  deleted\_at DATETIME(6),

  created\_at DATETIME(6),  
  updated\_at DATETIME(6)  
)

---

# **🔟 FILES \+ FILE\_LINKS (repositorio universal)**

## **FUSIÓN:**

La estructura actual ya es correcta y no se fusiona con otras tablas.

### **files**

files (  
  id CHAR(36) PRIMARY KEY,  
  company\_id CHAR(36) NOT NULL,  
  user\_id CHAR(36) NOT NULL,  
  mime\_type VARCHAR(200),  
  size INT,  
  path VARCHAR(500),

  status ENUM('active','archived','deleted') NOT NULL DEFAULT 'active',  
  deleted\_at DATETIME(6),

  created\_at DATETIME(6)  
)

### **file\_links**

file\_links (  
  id CHAR(36) PRIMARY KEY,  
  file\_id CHAR(36) NOT NULL,  
  entity\_type VARCHAR(100) NOT NULL,  
  entity\_id CHAR(36) NOT NULL,  
  status ENUM('active','deleted') NOT NULL DEFAULT 'active',  
  deleted\_at DATETIME(6),

  created\_at DATETIME(6)  
)

---

# **1️⃣1️⃣ AUDIT\_LOG (auditoría universal)**

Versión mejorada final:

audit\_log (  
  id CHAR(36) PRIMARY KEY,  
  company\_id CHAR(36) NULL,  
  user\_id CHAR(36) NULL,  
  entity\_type VARCHAR(100) NOT NULL,  
  entity\_id CHAR(36) NOT NULL,

  action ENUM('create','update','delete','archive','restore','security') NOT NULL,  
  snapshot\_before JSON,  
  snapshot\_after JSON,  
  metadata JSON,

  created\_at DATETIME(6) NOT NULL  
)

---

# **1️⃣2️⃣ USER\_LEGAL\_ACCEPTANCES**

(Normalizado y completo)

user_legal_acceptances (  
  id CHAR(36) PRIMARY KEY,  
  user_id CHAR(36) NOT NULL,  
  document_type ENUM('tos','privacy','cookies') NOT NULL,  
  document_version VARCHAR(50) NOT NULL,  
  accepted_at DATETIME(6) NOT NULL,

  created_at DATETIME(6)  
)

---

Perfecto. Acá tenés el **DOCUMENTO DE SCOPE OFICIAL**.  
Esto es **contrato de alcance**, corto, explícito y sin interpretaciones.  
---

## **Documento de Scope Oficial (Congelado)**

---

## **🎯 Propósito del documento**

Este documento define **qué incluye y qué NO incluye** la **FASE 1 – CORE PLATFORM**.

Su función es:

* evitar inflación de alcance  
* eliminar ambigüedades  
* servir como **límite contractual**  
* permitir avanzar rápido a fases posteriores sin rehacer nada

Si algo **no está explícitamente incluido**, **no pertenece a la Fase 1**.

---

## **🟢 ALCANCE INCLUIDO — FASE 1**

La Fase 1 cubre **exclusivamente el núcleo estructural del sistema**.

### **1️⃣ Identidad y acceso**

* Usuarios (users)  
* Estados de usuario  
* Bloqueos automáticos y manuales  
* Verificación de email  
* Recuperación de contraseña  
* Aceptación de términos legales  
* Sesiones con refresh tokens  
* Eventos de seguridad (login, locks, resets)

### **2️⃣ Seguridad**

* Registro de intentos de login  
* Detección de abuso  
* Bloqueos temporales  
* Auditoría de eventos de seguridad  
* No revelación de existencia de usuarios

### **3️⃣ Instalación inicial (bootstrap)**

* Sistema inicia sin usuarios  
* Primer usuario → `superadmin`  
* Bloqueo permanente del modo instalación  
* Sistema idempotente

### **4️⃣ Multiempresa (tenancy)**

* Empresas (companies)  
* Relación usuario–empresa (memberships)  
* Roles por empresa (owner, admin, member, viewer)  
* Protección de ownership (no dejar empresa sin owner)  
* Invitaciones a empresas por email  
* Cambio de contexto de empresa por sesión

### **5️⃣ Configuración básica**

* Configuración por empresa (company\_settings)  
* Preferencias mínimas de usuario (cuando aplique)

### **6️⃣ Archivos**

* Repositorio universal de archivos  
* Asociación flexible de archivos a entidades  
* Prohibición de borrado físico automático

### **7️⃣ Auditoría**

* Auditoría universal de cambios  
* Auditoría de seguridad separada  
* Registros append-only  
* No modificables  
* No eliminables

### **8️⃣ Reglas transversales**

* No borrado físico  
* Borrado lógico con `status` y `deleted_at`  
* Regla padre–hijo tipo 4equim  
* UUID globales  
* Preparado para integraciones futuras (sin implementarlas)

---

## **🔴 ALCANCE EXCLUIDO — FASE 1**

**Todo lo siguiente queda EXPLÍCITAMENTE fuera de la Fase 1**  
y será tratado en fases posteriores.

### **❌ Negocio / ERP**

* Clientes  
* Proveedores  
* Productos / servicios  
* Ventas  
* Compras  
* Stock  
* Órdenes de trabajo  
* Precios  
* Facturación

### **❌ Contabilidad (ACCCORE)**

* Asientos contables  
* Plan de cuentas  
* Impuestos  
* Balances  
* Cierres contables  
* Reportes financieros

### **❌ Permisos finos**

* Permisos por módulo  
* Permisos por acción  
* ACL detallado  
* Feature flags por rol

### **❌ Automatización y jobs**

* Tareas programadas  
* Workers  
* Colas  
* Procesos automáticos

### **❌ Integraciones**

* API pública  
* Webhooks  
* Integraciones externas  
* Sincronización con terceros

### **❌ UI / UX**

* Diseño visual  
* Frontend  
* Mobile UI  
* Experiencia de usuario

### **❌ Reporting**

* Dashboards  
* Métricas de negocio  
* KPIs

---

## **🧱 Regla de oro del Scope**

**FASE 1 \= infraestructura, identidad, seguridad y tenant.**  
**FASE 1 ≠ negocio.**

Cualquier funcionalidad que:

* genere dinero  
* represente operaciones  
* impacte contabilidad  
* dependa de reglas comerciales

👉 **NO pertenece a Fase 1\.**

---

## **🔒 Estado del Scope**

* **Estado:** CONGELADO  
* **Modificable:** ❌ No  
* **Cambio de alcance:** solo mediante apertura formal de nueva fase

---

## **✅ Conclusión**

Este documento:

* cierra definitivamente el alcance de la Fase 1  
* protege al sistema de sobreingeniería  
* habilita avanzar rápido a Fase 2 sin deuda  
* sirve como contrato técnico y de producto

---

## **EVENTOS AUDITABLES**

### **Objetivo**

Dejar **explícito** qué acciones **SIEMPRE** generan auditoría.  
Nada queda implícito. Nada “a criterio”.

---

## **🧾 EVENTOS QUE DEBEN AUDITARSE (OBLIGATORIOS)**

### **Usuarios**

* create user  
* update user  
* change status (pending/active/locked/disabled/deleted)  
* manual lock / unlock  
* email verified  
* password reset (used)

### **Seguridad**

* login\_success  
* login\_failed  
* auto\_lock  
* auto\_unlock  
* session revoked  
* install completed

### **Empresas**

* create company  
* update company  
* change company status  
* archive company  
* delete (lógico) company

### **Membresías**

* invite user  
* accept invitation  
* reject / revoke invitation  
* add membership  
* remove membership (logical)  
* change membership role  
* last owner protection triggered (evento explícito)

### **Configuración**

* create setting  
* update setting  
* delete (logical) setting

### **Archivos**

* upload file  
* link file  
* unlink file  
* archive file  
* delete (logical) file

### **Legal**

* accept TOS / privacy  
* change legal version required

---

## **📌 REGLAS DURAS**

* Todo evento auditado:  
  * **quién** (user\_id o system)  
  * **cuándo**  
  * **qué entidad**  
  * **antes / después**  
* Auditoría:  
  * append-only  
  * no editable  
  * no eliminable  
* Eventos de seguridad **también** se reflejan en `audit_log` (tipo `security`).

---

## **FLUJO DE INSTALACIÓN INICIAL**

### **Objetivo**

Garantizar **arranque desde cero** sin riesgo de takeover.

---

1. **Estado inicial del sistema**  
   * Sistema arranca como **NO INSTALADO**.  
   * No existe ningún usuario válido.  
2. **Endpoint de instalación**  
   * Solo disponible mientras `APP_INSTALLED = false`.  
   * Permite crear **UN SOLO usuario inicial**.  
3. **Primer usuario**  
   * Se convierte automáticamente en:  
     * `superadmin`  
     * `owner` de la empresa inicial (si se crea)  
   * Email **debe verificarse**.  
4. **Empresa inicial**  
   * Opcional.  
   * Si se crea, queda asociada al usuario inicial como `owner`.  
5. **Cierre del modo instalación**  
   * Al finalizar:  
     * `APP_INSTALLED = true`  
     * Endpoint de instalación queda **bloqueado permanentemente**.  
   * Evento auditado: `install_completed`.  
6. **Post-instalación**  
   * Cualquier nuevo usuario:  
     * solo por invitación  
     * o por flujo controlado normal

---

## **FLUJO DE LOGIN (AUTENTICACIÓN)**

### **Objetivo**

Permitir acceso seguro al sistema **sin revelar información sensible**, con control de abuso y trazabilidad total.

---

### **📌 Precondiciones**

* Sistema instalado (`APP_INSTALLED = true`)  
* Usuario existente o no (el flujo **no debe revelar** cuál de los dos casos aplica)

---

### **🔁 Flujo secuencial**

1. **Recepción de credenciales**  
   * Se recibe `email + password`  
   * Respuesta genérica ante error (siempre igual)  
2. **Registro del intento**  
   * Se registra **siempre** un evento de seguridad:  
     * `login_failed` o `login_success`  
   * Se guarda:  
     * email  
     * ip  
     * user\_agent  
     * timestamp  
3. **Validaciones de estado**  
   * Si `status = deleted | disabled` → rechazo silencioso  
   * Si `status = locked`:  
     * si `locked_until` venció → desbloqueo automático \+ evento  
     * si no → rechazo  
4. **Chequeo de credenciales**  
   * Comparación segura del hash  
   * Sin early-exit (timing attack safe)  
5. **Política de bloqueo automático**  
   * N intentos fallidos en ventana T → `locked`  
   * Se setea `locked_until`  
   * Evento: `auto_lock`  
6. **Login exitoso**  
   * Se crea sesión:  
     * refresh token único  
     * expiración  
   * Se asigna empresa activa:  
     * última usada  
     * o primera disponible  
   * Evento: `login_success`  
7. **Respuesta**  
   * Tokens \+ metadata mínima  
   * Nunca:  
     * estados internos  
     * razones de bloqueo  
     * confirmación de existencia de usuario

---

### **🔒 Reglas duras**

* El sistema **no dice**:  
  * “usuario no existe”  
  * “password incorrecto”  
  * “usuario bloqueado”  
* Todas las respuestas de error son equivalentes.  
* Todos los eventos quedan auditados.  
* Login **nunca** modifica datos de negocio.

---

### **✔ Resultado**

* Login seguro  
* Sin filtraciones  
* Preparado para rate-limit y MFA futuro  
* Auditable y escalable

---

## **✅ PASO 9 — LOGOUT & REVOCACIÓN DE SESIONES**

### **Objetivo**

Garantizar que **una sesión pueda invalidarse inmediatamente** sin afectar otras ni dejar residuos de seguridad.

---

### **🔁 Flujo de logout (usuario)**

1. **Solicitud de logout**  
   * Se recibe identificador de sesión / refresh token.  
   * No se revela estado previo.  
2. **Revocación**  
   * La sesión se marca como **revocada**.  
   * Se invalida el refresh token.  
3. **Auditoría**  
   * Evento de seguridad registrado:  
     * `session_revoked`  
   * Actor \= usuario.  
4. **Respuesta**  
   * Siempre exitosa (idempotente).

---

### **🔒 Revocación forzada (sistema)**

Se revocan **todas las sesiones activas** del usuario cuando:

* usuario pasa a `locked`  
* usuario pasa a `disabled`  
* usuario pasa a `deleted`  
* cambio de contraseña  
* reset de contraseña usado

Eventos auditados correspondientes.

---

### **🧱 Reglas duras**

* Logout **no elimina** la sesión, la invalida.  
* Tokens revocados **no pueden reutilizarse**.  
* Revocar una sesión **no impacta** otras (salvo revocación forzada).  
* Repetir logout **no genera error**.

---

### **✔ Resultado**

* Cierre de sesión inmediato  
* Control total del acceso  
* Sin efectos colaterales  
* Auditoría completa

---

---

## **✅ PASO 10 — RECUPERACIÓN DE CONTRASEÑA**

### **Objetivo**

Permitir restablecer contraseña **sin filtrar información**, con control total y trazabilidad.

---

### **🔁 Flujo end-to-end**

1. **Solicitud de reset**  
   * Se recibe email.  
   * Respuesta **siempre genérica** (exista o no el usuario).  
   * Evento de seguridad registrado:  
     * `password_reset_requested`.  
2. **Generación de token**  
   * Token:  
     * único  
     * de un solo uso  
     * con vencimiento corto.  
   * Asociado al usuario si existe.  
   * Nunca se expone el user\_id.  
3. **Envío**  
   * Se envía link con token.  
   * Reenviable, invalida tokens anteriores activos.  
4. **Uso del token**  
   * Se valida:  
     * no expirado  
     * no usado  
   * Se establece nueva contraseña.  
   * Se invalidan **todas las sesiones activas**.  
   * Evento: `password_reset_used`.  
5. **Cierre**  
   * Token marcado como usado.  
   * Usuario queda en estado `active` (si no estaba `disabled/deleted`).

---

### **🔒 Reglas duras**

* Nunca se informa si el email existe.  
* Tokens:  
  * no reutilizables  
  * no extensibles  
* Reset **no desbloquea** usuarios `disabled` o `deleted`.  
* Todo el flujo queda auditado.

---

### **✔ Resultado**

* Recuperación segura  
* Sin filtraciones  
* Sin sesiones zombie  
* Lista para producción real

---

---

## **✅ PASO 11 — VERIFICACIÓN DE EMAIL**

### **Objetivo**

Confirmar la **identidad del email** antes de habilitar acceso operativo.

---

### **🔁 Flujo end-to-end**

1. **Generación del token**  
   * Token:  
     * único  
     * de un solo uso  
     * con vencimiento.  
   * Asociado al usuario en estado `pending`.  
2. **Envío**  
   * Se envía email con link de verificación.  
   * Reenvío permitido.  
   * Cada reenvío invalida tokens previos activos.  
   * Evento: `email_verification_sent`.  
3. **Uso del token**  
   * Validación:  
     * existe  
     * no expirado  
     * no usado  
   * Se marca:  
     * `email_verified_at`  
     * `status = active`  
   * Evento: `email_verified`.  
4. **Respuesta**  
   * Éxito genérico.  
   * Nunca revela estado interno previo.

---

### **🔒 Reglas duras**

* Un usuario **no puede operar** sin email verificado.  
* Verificar email **no crea sesión automáticamente**.  
* Tokens:  
  * no reutilizables  
  * no prorrogables.  
* Usuarios `disabled` o `deleted` **no pueden verificarse**.  
* Todo evento queda auditado.

---

### **✔ Resultado**

* Identidad validada  
* Menos spam / cuentas basura  
* Base legal y de seguridad sólida

---

---

## **✅ PASO 12 — ACEPTACIÓN LEGAL OBLIGATORIA**

### **Objetivo**

Garantizar **cumplimiento legal** antes de cualquier uso operativo del sistema.

---

### **🔁 Flujo end-to-end**

1. **Definición de documentos activos**  
   * Tipos: `tos`, `privacy`, `cookies`  
   * Cada uno con **versión vigente**.  
2. **Chequeo previo**  
   * En login / primera operación:  
     * si falta aceptación de **algún documento vigente** → acceso **bloqueado** a funciones operativas.  
3. **Presentación**  
   * Se muestra documento \+ versión.  
   * Aceptación **explícita** (no implícita).  
4. **Registro**  
   * Se guarda:  
     * user\_id  
     * document\_type  
     * document\_version  
     * timestamp  
   * Evento auditado: `legal_accepted`.  
5. **Cambio de versión**  
   * Nueva versión invalida aceptaciones previas.  
   * Usuario debe **reaceptar**.

---

### **🔒 Reglas duras**

* Sin aceptación → **no hay operación**.  
* Aceptación:  
  * es **inmutable**  
  * no se edita  
  * no se elimina.  
* Usuarios `disabled` o `deleted` **no aceptan**.  
* Aceptar legal **no crea sesión** ni modifica seguridad.

---

### **✔ Resultado**

* Cobertura legal sólida  
* Prueba histórica de aceptación  
* Preparado para monetización y compliance

---

---

## **✅ PASO 13 — FLUJOS MULTIEMPRESA (USO REAL)**

### **Objetivo**

Permitir que un usuario **opere correctamente en múltiples empresas** sin cruces, sin ambigüedad y con control total.

---

### **🏢 1\) Creación de empresa**

**Quién puede crear**

* Usuario `active`  
* Con rol global válido  
* O miembro con permiso de creación (definido a nivel producto)

**Reglas**

* La empresa nace:  
  * `status = active`  
  * con **al menos un owner**  
* El creador queda como `owner` automáticamente.  
* Evento auditado: `company_created`.

---

### **✉️ 2\) Invitación a empresa**

**Flujo**

1. Owner/Admin invita por email.  
2. Se crea invitación con:  
   * rol asignado  
   * expiración  
3. Evento: `company_invite_sent`.

**Reglas**

* Invitación:  
  * es única  
  * no reutilizable  
  * expira  
* Invitar a email ya miembro → rechazo explícito.

---

### **✅ 3\) Aceptación / rechazo**

**Aceptar**

* Si usuario existe → se crea membership.  
* Si no existe → se crea usuario `pending`.  
* Se asigna rol.  
* Evento: `company_invite_accepted`.

**Rechazar**

* No crea membership.  
* Evento: `company_invite_rejected`.

---

### **🔁 4\) Cambio de contexto de empresa**

**Reglas**

* Un usuario solo puede operar dentro de:  
  * una empresa activa  
  * de la que sea miembro activo  
* El contexto:  
  * se guarda por sesión  
  * no es implícito  
* Evento: `company_context_changed`.

---

### **🔒 5\) Protección de ownership**

* Una empresa **nunca** puede quedar sin `owner`.  
* Intentar remover al último owner:  
  * operación bloqueada  
  * evento auditado: `last_owner_protection`.

---

### **🧱 6\) Salida de empresa**

**Reglas**

* Un usuario puede salir de una empresa.  
* No puede salir si es el último owner.  
* Evento: `membership_left`.

---

### **✔ Resultado**

* Multiempresa real  
* Sin fugas de datos  
* Flujos claros para usuarios reales  
* Preparado para escalar a ERP

---

---

## **✅ PASO 14 — LIFECYCLE DE EMPRESAS**

### **Objetivo**

Definir **cómo una empresa cambia de estado** sin pérdida de datos ni inconsistencias.

---

### **🧭 Estados permitidos**

* `active` → operativa  
* `inactive` → pausada (sin nuevas operaciones)  
* `archived` → histórica, solo lectura  
* `deleted` → eliminación lógica (no visible, no operable)

---

### **🔁 Transiciones válidas**

1. **active → inactive**  
   * Permitido siempre.  
   * No elimina datos.  
   * Evento: `company_deactivated`.  
2. **inactive → active**  
   * Permitido si no hay bloqueos legales.  
   * Evento: `company_reactivated`.  
3. **active / inactive → archived**  
   * Requiere:  
     * cero operaciones activas  
     * usuarios notificados  
   * Empresa queda **solo lectura**.  
   * Evento: `company_archived`.  
4. **archived → active**  
   * Permitido por owner/superadmin.  
   * Evento: `company_restored`.  
5. **archived → deleted**  
   * Requiere:  
     * sin datos activos dependientes  
     * confirmación explícita  
   * Marca `deleted_at`.  
   * Evento: `company_deleted_logical`.

---

### **🔒 Reglas duras**

* **Nunca** borrado físico.  
* **Nunca** dejar empresa sin `owner`.  
* No se puede:  
  * archivar si hay operaciones activas  
  * eliminar si hay dependencias activas  
* Toda transición es **auditada**.

---

### **✔ Resultado**

* Ciclo de vida claro y seguro  
* Historial intacto  
* Preparado para compliance y soporte

---

---

## **✅ PASO 15 — LIFECYCLE DE USUARIOS**

### **Objetivo**

Definir **cómo evoluciona un usuario** desde su creación hasta su eliminación lógica, **sin perder trazabilidad ni seguridad**.

---

### **🧭 Estados permitidos**

* `pending` → creado, email no verificado  
* `active` → puede operar  
* `locked` → bloqueo automático temporal  
* `disabled` → bloqueo manual administrativo  
* `deleted` → eliminación lógica (no visible, no accesible)

---

### **🔁 Transiciones válidas**

1. **pending → active**  
   * Requiere:  
     * verificación de email  
     * aceptación legal vigente  
   * Evento: `user_activated`.  
2. **active → locked**  
   * Automático por seguridad (intentos fallidos).  
   * Se define `locked_until`.  
   * Evento: `user_auto_locked`.  
3. **locked → active**  
   * Automático al vencer `locked_until`.  
   * Evento: `user_auto_unlocked`.  
4. **active → disabled**  
   * Manual (admin/superadmin).  
   * No reversible sin intervención explícita.  
   * Evento: `user_disabled`.  
5. **disabled → active**  
   * Manual (admin/superadmin).  
   * Evento: `user_reenabled`.  
6. **active / disabled → deleted**  
   * Eliminación lógica.  
   * Usuario:  
     * pierde acceso  
     * conserva historial  
   * Evento: `user_deleted_logical`.

---

### **🔒 Reglas duras**

* **Nunca** borrado físico.  
* Usuario `deleted`:  
  * no inicia sesión  
  * no acepta invitaciones  
  * no acepta legales  
* Bloqueos automáticos:  
  * **no** cambian membresías  
* Bloqueos manuales:  
  * revocan **todas** las sesiones.  
* Cambios de estado **siempre auditados**.

---

### **🧱 Relación con empresas**

* Eliminar lógicamente un usuario:  
  * **no elimina** empresas  
  * **no elimina** auditoría  
  * memberships pasan a `revoked`  
* No se puede eliminar:  
  * si es **último owner** de alguna empresa  
  * sin transferir ownership antes

---

### **✔ Resultado**

* Ciclo de vida claro  
* Seguridad total  
* Sin pérdida histórica  
* Compatible con crecimiento y compliance

---

---

## **✅ PASO 16 — LIFECYCLE DE MEMBRESÍAS Y ROLES**

### **Objetivo**

Definir **cómo un usuario entra, cambia y sale de una empresa**, y cómo evolucionan sus roles **sin romper ownership ni seguridad**.

---

## **🧭 Estados de company\_memberships**

* `invited` → invitación emitida, no aceptada  
* `active` → miembro operativo  
* `revoked` → acceso retirado por la empresa  
* `left` → salida voluntaria del usuario  
* `deleted` → eliminación lógica (histórica)

---

## **🔁 Transiciones válidas (membership)**

1. **invited → active**  
   * Invitación aceptada.  
   * Evento: `membership_activated`.  
2. **invited → revoked**  
   * Invitación cancelada.  
   * Evento: `membership_invite_revoked`.  
3. **active → revoked**  
   * Acción de owner/admin.  
   * Evento: `membership_revoked`.  
4. **active → left**  
   * Acción del usuario.  
   * Evento: `membership_left`.  
5. **revoked / left → active**  
   * Solo por nueva invitación.  
   * Evento: `membership_reactivated`.  
6. **any → deleted**  
   * Eliminación lógica histórica.  
   * Evento: `membership_deleted_logical`.

---

## **🧭 Estados de membership\_roles**

* `active`  
* `deleted`

---

## **🔁 Transiciones válidas (roles)**

1. **Asignación inicial**  
   * Se crea un rol activo.  
   * Evento: `role_assigned`.  
2. **Cambio de rol**  
   * Nuevo rol activo.  
   * Rol previo pasa a `deleted`.  
   * Evento: `role_changed`.  
3. **Eliminación lógica**  
   * Solo si existe otro rol activo.  
   * Evento: `role_deleted_logical`.

---

## **🔒 Reglas duras**

* Un membership tiene **un solo rol activo**.  
* Una empresa **no puede quedar sin owner**.  
* No se puede:  
  * revocar  
  * cambiar rol  
  * eliminar  
    a un membership si rompe la regla de ownership.  
* Todos los cambios:  
  * son explícitos  
  * son auditados.

---

## **🧱 Relación con usuarios y empresas**

* Desactivar un usuario:  
  * **no borra** memberships  
  * impide operar  
* Archivar empresa:  
  * memberships quedan solo lectura  
* Eliminar empresa lógicamente:  
  * memberships pasan a `deleted`

---

### **✔ Resultado**

* Control total de acceso por empresa  
* Ownership protegido  
* Historial intacto  
* Base sólida para permisos futuros

---

---

## **✅ PASO 17 — CIERRE FORMAL DE FASE 1**

### **Objetivo**

Declarar la **FASE 1 oficialmente terminada**, **congelada** y **lista para ser implementada** sin reinterpretaciones.

---

## **🧾 Checklist final (obligatorio)**

### **🔒 Arquitectura**

* Identidad global definida (users).  
* Multiempresa real sin cruces.  
* Roles gruesos, no permisos finos.  
* Sin borrado físico en entidades core.  
* Regla padre–hijo aplicada a todo.

### **🧭 Ciclos de vida**

* Usuarios: definidos y auditados.  
* Empresas: definidos y auditados.  
* Membresías y roles: definidos y protegidos.  
* Sesiones y seguridad: definidos end-to-end.

### **🔐 Seguridad**

* Login seguro sin filtrado de información.  
* Bloqueos automáticos y manuales.  
* Tokens seguros y revocables.  
* Auditoría de eventos críticos y de seguridad.

### **🧾 Auditoría y legal**

* Audit log universal, append-only.  
* Eventos de seguridad separados y auditados.  
* Aceptación legal versionada e inmutable.

### **🧱 Scope**

* Alcance incluido/excluido documentado.  
* Fase 1 **no contiene negocio**.  
* Fase 1 **no contiene contabilidad**.  
* Fase 1 **no contiene permisos finos**.

---

## **🔒 Estado oficial**

* **Fase:** CORE PLATFORM – FASE 1  
* **Estado:** CERRADA / CONGELADA  
* **Modificable:** ❌ No  
* **Cambios:** solo mediante apertura formal de Fase 2+  
* **Uso:** contrato técnico y de producto

---

## **📌 Declaración final**

“Este documento define el núcleo inmutable del sistema.  
Cualquier implementación debe ajustarse a estas reglas sin excepción.”

Con esto:

* no hay deuda conceptual  
* no hay ambigüedades  
* no hay decisiones postergadas  
* el sistema es escalable y seguro por diseño

---

