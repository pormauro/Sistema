-- =====================================================================
--  SISA - CORE PLATFORM (FASE 1)
--  SCHEMA COMPLETO • VERSION FINAL Y CONGELADA
-- =====================================================================

-- ============================================================
-- 0) EXTENSIONES / CONFIG
-- ============================================================

SET NAMES utf8mb4;
SET time_zone = "+00:00";

-- =====================================================================
-- 1) USERS
-- =====================================================================

CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,

    status ENUM('pending','active','locked','disabled','deleted') NOT NULL DEFAULT 'pending',
    locked_until DATETIME(6) NULL,
    email_verified_at DATETIME(6) NULL,
    deleted_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL
);

-- =====================================================================
-- 2) USER_SECURITY_EVENTS
-- =====================================================================

CREATE TABLE user_security_events (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NULL,
    email VARCHAR(255) NOT NULL,
    ip_address VARCHAR(100),
    user_agent VARCHAR(500),

    event_type ENUM(
        'login_success',
        'login_failed',
        'password_reset_requested',
        'password_reset_used',
        'email_verification_sent',
        'email_verified',
        'auto_lock',
        'auto_unlock',
        'manual_lock',
        'manual_unlock'
    ) NOT NULL,

    metadata JSON NULL,
    created_at DATETIME(6) NOT NULL,

    INDEX (email),
    INDEX (user_id),
    INDEX (event_type),
    INDEX (created_at)
);

-- =====================================================================
-- 3) USER_ROLES (roles globales)
-- =====================================================================

CREATE TABLE user_roles (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    role ENUM('superadmin','system') NOT NULL,
    
    status ENUM('active','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6) NULL,

    created_at DATETIME(6),
    updated_at DATETIME(6),

    INDEX (user_id)
);

-- =====================================================================
-- 4) USER_SESSIONS
-- =====================================================================

CREATE TABLE user_sessions (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    active_company_id CHAR(36) NULL,

    refresh_token VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(100),
    user_agent VARCHAR(500),

    expires_at DATETIME(6) NOT NULL,
    revoked_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (user_id),
    INDEX (active_company_id),
    INDEX (expires_at)
);

-- =====================================================================
-- 5) COMPANIES
-- =====================================================================

CREATE TABLE companies (
    id CHAR(36) PRIMARY KEY,
    legal_name VARCHAR(255) NOT NULL,
    trade_name VARCHAR(255),
    tax_id VARCHAR(50),

    status ENUM('active','inactive','archived','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6),

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL
);

-- =====================================================================
-- 6) COMPANY_INVITATIONS
-- =====================================================================

CREATE TABLE company_invitations (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role ENUM('owner','admin','member','viewer') NOT NULL,
    token CHAR(36) NOT NULL,

    status ENUM('pending','accepted','rejected','expired','revoked') NOT NULL,
    expires_at DATETIME(6),
    accepted_at DATETIME(6),

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (email),
    INDEX (token)
);

-- =====================================================================
-- 7) COMPANY_MEMBERSHIPS
-- =====================================================================

CREATE TABLE company_memberships (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,

    status ENUM('active','invited','revoked','left','deleted') NOT NULL,
    deleted_at DATETIME(6),

    created_at DATETIME(6),
    updated_at DATETIME(6),

    INDEX (company_id),
    INDEX (user_id),
    INDEX (status)
);

-- =====================================================================
-- 8) MEMBERSHIP_ROLES
-- =====================================================================

CREATE TABLE membership_roles (
    id CHAR(36) PRIMARY KEY,
    membership_id CHAR(36) NOT NULL,
    role ENUM('owner','admin','member','viewer') NOT NULL,

    status ENUM('active','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6),

    created_at DATETIME(6),
    updated_at DATETIME(6),

    INDEX (membership_id),
    INDEX (role)
);

-- =====================================================================
-- 9) COMPANY_SETTINGS
-- =====================================================================

CREATE TABLE company_settings (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,

    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT NULL,

    status ENUM('active','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6),

    created_at DATETIME(6),
    updated_at DATETIME(6),

    INDEX (company_id),
    INDEX (setting_key)
);

-- =====================================================================
-- 10) FILES
-- =====================================================================

CREATE TABLE files (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,

    mime_type VARCHAR(200),
    size INT,
    path VARCHAR(500),

    status ENUM('active','archived','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6),

    created_at DATETIME(6),

    INDEX (company_id),
    INDEX (user_id)
);

-- =====================================================================
-- 11) FILE_LINKS
-- =====================================================================

CREATE TABLE file_links (
    id CHAR(36) PRIMARY KEY,
    file_id CHAR(36) NOT NULL,

    entity_type VARCHAR(100) NOT NULL,
    entity_id CHAR(36) NOT NULL,

    status ENUM('active','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6),

    created_at DATETIME(6),

    INDEX (file_id),
    INDEX (entity_type),
    INDEX (entity_id)
);

-- =====================================================================
-- 12) AUDIT_LOG
-- =====================================================================

CREATE TABLE audit_log (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NULL,
    user_id CHAR(36) NULL,

    entity_type VARCHAR(100) NOT NULL,
    entity_id CHAR(36) NOT NULL,

    action ENUM('create','update','delete','archive','restore','security') NOT NULL,
    snapshot_before JSON,
    snapshot_after JSON,
    metadata JSON,

    created_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (user_id),
    INDEX (entity_type),
    INDEX (entity_id),
    INDEX (action)
);

-- =====================================================================
-- 13) USER_LEGAL_ACCEPTANCES
-- =====================================================================

CREATE TABLE user_legal_acceptances (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,

    document_type ENUM('tos','privacy','cookies') NOT NULL,
    document_version VARCHAR(50) NOT NULL,
    accepted_at DATETIME(6) NOT NULL,

    created_at DATETIME(6),

    INDEX (user_id),
    INDEX (document_type)
);

-- =====================================================================
-- FIN DEL SCHEMA FASE 1
-- =====================================================================
