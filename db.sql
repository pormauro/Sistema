/* ======================================================================
   SISA_SYNC — Schema SQL completo (MySQL 8 / MariaDB 10.6+)
   Base lógica: sisa_sync
   Objetivo: Offline queue + batches + conflicts + resolutions + devices + sync cursors
   NOTA: Esta base NO depende físicamente de Core/ERP/ACCCORE.
         user_id/company_id se guardan como UUID referenciales (sin FK cross-DB).
   ====================================================================== */

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- Recomendado: usar una DB dedicada (ajustá nombre si querés)
-- CREATE DATABASE IF NOT EXISTS sisa_sync CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE sisa_sync;

-- Para evitar sorpresas en migrations repetidas:
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS sync_conflict_resolutions;
DROP TABLE IF EXISTS sync_conflicts;
DROP TABLE IF EXISTS sync_queue;
DROP TABLE IF EXISTS sync_batches;
DROP TABLE IF EXISTS last_sync_state;
DROP TABLE IF EXISTS device_sessions;
DROP TABLE IF EXISTS device_registry;

SET FOREIGN_KEY_CHECKS = 1;

/* ======================================================================
   1) device_registry
   Identidad física del emisor (dispositivo)
   ====================================================================== */
CREATE TABLE device_registry (
  id                 CHAR(36)     NOT NULL,
  company_id          CHAR(36)     NULL,         -- referencia a Core.companies (si aplica)
  user_id             CHAR(36)     NULL,         -- referencia a Core.users (si aplica)
  device_fingerprint  VARCHAR(128) NOT NULL,     -- hash estable del dispositivo (app + hw + os)
  device_name         VARCHAR(120) NULL,         -- "Mauro-Note", "Tablet Planta", etc.
  platform            VARCHAR(32)  NOT NULL,     -- android | ios | web | desktop | other
  os_version          VARCHAR(64)  NULL,
  app_version         VARCHAR(64)  NULL,
  locale              VARCHAR(16)  NULL,
  timezone            VARCHAR(64)  NULL,
  is_trusted          TINYINT(1)   NOT NULL DEFAULT 0,
  trust_reason        VARCHAR(255) NULL,

  -- Auditoría mínima
  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  last_seen_at        DATETIME(3)  NULL,
  revoked_at          DATETIME(3)  NULL,
  revoked_reason      VARCHAR(255) NULL,

  PRIMARY KEY (id),
  UNIQUE KEY uq_device_fingerprint (device_fingerprint),
  KEY idx_device_company (company_id),
  KEY idx_device_user (user_id),
  KEY idx_device_last_seen (last_seen_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   2) device_sessions (opcional pero muy útil)
   Sesiones técnicas del dispositivo para trazabilidad + seguridad
   ====================================================================== */
CREATE TABLE device_sessions (
  id                 CHAR(36)     NOT NULL,
  device_id           CHAR(36)     NOT NULL,
  company_id          CHAR(36)     NULL,
  user_id             CHAR(36)     NULL,

  -- Token técnico (no es JWT de login, es sesión de sync)
  session_token_hash  CHAR(64)     NOT NULL,     -- SHA-256 hex del token
  started_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  ended_at            DATETIME(3)  NULL,

  ip_address          VARCHAR(64)  NULL,
  user_agent          VARCHAR(255) NULL,

  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  PRIMARY KEY (id),
  UNIQUE KEY uq_device_session_token_hash (session_token_hash),
  KEY idx_device_sessions_device (device_id),
  KEY idx_device_sessions_company (company_id),
  KEY idx_device_sessions_user (user_id),
  KEY idx_device_sessions_started (started_at),
  CONSTRAINT fk_device_sessions_device
    FOREIGN KEY (device_id) REFERENCES device_registry(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   3) sync_batches
   Agrupa envíos al servidor (replay, auditoría, rollback lógico)
   ====================================================================== */
CREATE TABLE sync_batches (
  id                 CHAR(36)     NOT NULL,
  device_id           CHAR(36)     NOT NULL,
  device_session_id   CHAR(36)     NULL,         -- referencia a device_sessions.id si usás
  company_id          CHAR(36)     NULL,
  user_id             CHAR(36)     NULL,

  direction           ENUM('up','down','mixed') NOT NULL DEFAULT 'up',
  status              ENUM('created','sending','sent','acknowledged','failed','cancelled') NOT NULL DEFAULT 'created',

  -- Conteos (útiles para métricas y validaciones)
  items_total         INT UNSIGNED NOT NULL DEFAULT 0,
  items_sent          INT UNSIGNED NOT NULL DEFAULT 0,
  items_acked         INT UNSIGNED NOT NULL DEFAULT 0,
  items_failed        INT UNSIGNED NOT NULL DEFAULT 0,
  conflicts_detected  INT UNSIGNED NOT NULL DEFAULT 0,

  -- Integridad / debugging
  payload_hash        CHAR(64)     NULL,          -- hash del JSON enviado
  server_ack_hash     CHAR(64)     NULL,          -- hash de la respuesta del server
  error_code          VARCHAR(64)  NULL,
  error_message       VARCHAR(255) NULL,

  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  started_at          DATETIME(3)  NULL,
  finished_at         DATETIME(3)  NULL,

  PRIMARY KEY (id),
  KEY idx_batches_device (device_id),
  KEY idx_batches_session (device_session_id),
  KEY idx_batches_company (company_id),
  KEY idx_batches_user (user_id),
  KEY idx_batches_status (status),
  KEY idx_batches_created (created_at),
  CONSTRAINT fk_sync_batches_device
    FOREIGN KEY (device_id) REFERENCES device_registry(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_sync_batches_device_session
    FOREIGN KEY (device_session_id) REFERENCES device_sessions(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   4) sync_queue
   Cola local (o espejo server-side) de operaciones pendientes.
   - No interpreta negocio.
   - No valida estados.
   ====================================================================== */
CREATE TABLE sync_queue (
  id                  CHAR(36)     NOT NULL,
  batch_id            CHAR(36)     NULL,          -- asignado cuando se empaqueta
  device_id           CHAR(36)     NOT NULL,
  device_session_id   CHAR(36)     NULL,
  company_id          CHAR(36)     NULL,
  user_id             CHAR(36)     NULL,

  -- Identidad del objeto afectado
  entity              VARCHAR(64)  NOT NULL,      -- ej: "jobs", "invoices", "files"
  entity_id           CHAR(36)     NOT NULL,      -- UUID del registro en su bounded context
  entity_version      BIGINT UNSIGNED NULL,       -- version local (si aplica)
  operation           ENUM('create','update','delete') NOT NULL,

  -- Estado de la cola
  status              ENUM('queued','packed','sending','sent','acked','failed','conflict','cancelled') NOT NULL DEFAULT 'queued',
  attempt_count       INT UNSIGNED NOT NULL DEFAULT 0,
  next_retry_at       DATETIME(3)  NULL,

  -- Tiempos (local y servidor)
  local_created_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  local_occurred_at   DATETIME(3)  NULL,          -- momento real del evento en el dispositivo
  server_received_at  DATETIME(3)  NULL,
  server_acked_at     DATETIME(3)  NULL,

  -- Payloads
  payload             JSON         NOT NULL,      -- data del change (nuevo/patch)
  before_snapshot     JSON         NULL,          -- opcional: estado previo si se capturó
  checksum            CHAR(64)     NULL,          -- hash del payload (integridad)

  -- Errores
  last_error_code     VARCHAR(64)  NULL,
  last_error_message  VARCHAR(255) NULL,

  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

  PRIMARY KEY (id),

  KEY idx_queue_batch (batch_id),
  KEY idx_queue_device (device_id),
  KEY idx_queue_session (device_session_id),
  KEY idx_queue_company (company_id),
  KEY idx_queue_user (user_id),

  KEY idx_queue_entity (entity, entity_id),
  KEY idx_queue_status (status),
  KEY idx_queue_retry (next_retry_at),
  KEY idx_queue_created (created_at),

  -- Evita duplicados obvios si el cliente reintenta mal:
  UNIQUE KEY uq_queue_dedupe (device_id, entity, entity_id, operation, checksum),

  CONSTRAINT fk_sync_queue_batch
    FOREIGN KEY (batch_id) REFERENCES sync_batches(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  CONSTRAINT fk_sync_queue_device
    FOREIGN KEY (device_id) REFERENCES device_registry(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_sync_queue_device_session
    FOREIGN KEY (device_session_id) REFERENCES device_sessions(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   5) sync_conflicts
   Registro de TODO conflicto detectado (bloquea ejecución).
   ====================================================================== */
CREATE TABLE sync_conflicts (
  id                 CHAR(36)     NOT NULL,
  batch_id            CHAR(36)     NULL,
  queue_item_id       CHAR(36)     NULL,          -- el item de cola que disparó el conflicto (si aplica)
  device_id           CHAR(36)     NOT NULL,
  device_session_id   CHAR(36)     NULL,
  company_id          CHAR(36)     NULL,
  user_id             CHAR(36)     NULL,

  entity              VARCHAR(64)  NOT NULL,
  entity_id           CHAR(36)     NOT NULL,
  operation           ENUM('create','update','delete') NOT NULL,

  -- Tipo y severidad de conflicto
  conflict_type       ENUM(
                      'version_mismatch',
                      'missing_server_record',
                      'already_exists_server',
                      'state_machine_violation',
                      'permission_denied',
                      'unique_constraint',
                      'validation_failed',
                      'schema_incompatible',
                      'unknown'
                    ) NOT NULL DEFAULT 'unknown',
  severity            ENUM('low','medium','high','critical') NOT NULL DEFAULT 'high',

  -- Estado del conflicto
  status              ENUM('open','investigating','resolved','dismissed') NOT NULL DEFAULT 'open',

  -- Payloads para forensics (sin magia: evidencia, no input)
  local_payload       JSON         NOT NULL,
  server_payload      JSON         NULL,
  server_error        JSON         NULL,          -- error estructurado del server (si vino)
  reason              VARCHAR(255) NULL,

  -- Fingerprints para integridad
  local_checksum      CHAR(64)     NULL,
  server_checksum     CHAR(64)     NULL,

  detected_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

  PRIMARY KEY (id),

  KEY idx_conflicts_batch (batch_id),
  KEY idx_conflicts_queue_item (queue_item_id),
  KEY idx_conflicts_device (device_id),
  KEY idx_conflicts_company (company_id),
  KEY idx_conflicts_user (user_id),

  KEY idx_conflicts_entity (entity, entity_id),
  KEY idx_conflicts_status (status),
  KEY idx_conflicts_type (conflict_type),
  KEY idx_conflicts_detected (detected_at),

  CONSTRAINT fk_sync_conflicts_batch
    FOREIGN KEY (batch_id) REFERENCES sync_batches(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  CONSTRAINT fk_sync_conflicts_queue_item
    FOREIGN KEY (queue_item_id) REFERENCES sync_queue(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  CONSTRAINT fk_sync_conflicts_device
    FOREIGN KEY (device_id) REFERENCES device_registry(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_sync_conflicts_device_session
    FOREIGN KEY (device_session_id) REFERENCES device_sessions(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   6) sync_conflict_resolutions
   Cómo, cuándo y quién resolvió el conflicto (auditables).
   ====================================================================== */
CREATE TABLE sync_conflict_resolutions (
  id                 CHAR(36)     NOT NULL,
  conflict_id         CHAR(36)     NOT NULL,

  resolved_by_user_id CHAR(36)     NULL,          -- referencia Core.users
  resolved_by_device_id CHAR(36)   NULL,

  strategy            ENUM('manual','assisted','forced') NOT NULL DEFAULT 'manual',
  action              ENUM(
                      'keep_local',
                      'keep_server',
                      'merge',
                      'reapply_as_new',
                      'cancel_local_change',
                      'override_server'
                    ) NOT NULL,

  notes               VARCHAR(500) NULL,

  -- Evidencia de resolución
  resolution_payload  JSON         NULL,          -- merge result / chosen payload
  resolution_checksum CHAR(64)     NULL,

  resolved_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  PRIMARY KEY (id),
  UNIQUE KEY uq_resolution_one_per_conflict (conflict_id), -- 1 resolución final por conflicto
  KEY idx_resolutions_user (resolved_by_user_id),
  KEY idx_resolutions_device (resolved_by_device_id),
  KEY idx_resolutions_resolved (resolved_at),

  CONSTRAINT fk_conflict_resolutions_conflict
    FOREIGN KEY (conflict_id) REFERENCES sync_conflicts(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   7) last_sync_state
   Cursor / corte por entidad y dispositivo (sync incremental).
   ====================================================================== */
CREATE TABLE last_sync_state (
  id                 CHAR(36)     NOT NULL,
  device_id           CHAR(36)     NOT NULL,
  company_id          CHAR(36)     NULL,
  user_id             CHAR(36)     NULL,

  entity              VARCHAR(64)  NOT NULL,      -- "jobs", "accounts", "files", etc.

  -- Cursores posibles (usá 1 o más según tu estrategia)
  last_server_cursor  VARCHAR(128) NULL,          -- token/cursor opaco (si el server lo usa)
  last_server_id_max  BIGINT UNSIGNED NULL,       -- si sincronizás por history autoincremental
  last_server_time    DATETIME(3)  NULL,          -- si sincronizás por timestamp
  last_server_version BIGINT UNSIGNED NULL,       -- si version global

  -- Estado
  last_success_at     DATETIME(3)  NULL,
  last_attempt_at     DATETIME(3)  NULL,
  last_error_code     VARCHAR(64)  NULL,
  last_error_message  VARCHAR(255) NULL,

  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

  PRIMARY KEY (id),

  UNIQUE KEY uq_last_sync_state (device_id, company_id, entity),
  KEY idx_last_sync_company (company_id),
  KEY idx_last_sync_user (user_id),
  KEY idx_last_sync_entity (entity),
  KEY idx_last_sync_success (last_success_at),

  CONSTRAINT fk_last_sync_state_device
    FOREIGN KEY (device_id) REFERENCES device_registry(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/* ======================================================================
   Reglas de integridad operativa (comentarios, no triggers por ahora)
   ----------------------------------------------------------------------
   - sync_conflicts.status=open => NO permitir que el sistema "avance" en UI/negocio.
   - Un conflicto NO se borra.
   - Un conflicto NO se autocorrige.
   - PDFs/adjuntos son evidencia: NO alteran estados.
   ====================================================================== */
