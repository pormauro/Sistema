-- =====================================================================
--  SISA - ERP OPERATIVO (FASE 2)
--  SCHEMA COMPLETO • VERSION FINAL Y CONGELADA
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = "+00:00";


-- =====================================================================
-- 1) JOBS (ORDENES DE TRABAJO)
-- =====================================================================

CREATE TABLE jobs (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,

    status ENUM('planned','in_progress','paused','completed','cancelled')
        NOT NULL DEFAULT 'planned',

    type VARCHAR(100) NULL,
    assigned_user_id CHAR(36) NULL,

    planned_start DATETIME(6) NULL,
    planned_end DATETIME(6) NULL,

    completed_at DATETIME(6) NULL,
    cancelled_at DATETIME(6) NULL,
    cancelled_reason TEXT NULL,

    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (assigned_user_id),
    INDEX (status)
);

-- =====================================================================
-- 1.1) JOB_TIME_ENTRIES (tabla única, editable, auditada)
-- =====================================================================

CREATE TABLE job_time_entries (
    id CHAR(36) PRIMARY KEY,
    job_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,

    started_at DATETIME(6) NOT NULL,
    ended_at DATETIME(6) NOT NULL,
    minutes INT NOT NULL,

    status ENUM('active','deleted') NOT NULL DEFAULT 'active',
    deleted_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (job_id),
    INDEX (user_id),
    INDEX (status)
);


-- =====================================================================
-- 1.2) JOB_CHECKLIST_ITEMS (definición de items)
-- =====================================================================

CREATE TABLE job_checklist_items (
    id CHAR(36) PRIMARY KEY,
    job_id CHAR(36) NOT NULL,

    label VARCHAR(255) NOT NULL,
    position INT NOT NULL DEFAULT 0,

    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (job_id)
);

-- =====================================================================
-- 1.3) JOB_CHECKLIST_EXECUTION (ejecuciones reales)
-- =====================================================================

CREATE TABLE job_checklist_execution (
    id CHAR(36) PRIMARY KEY,
    checklist_item_id CHAR(36) NOT NULL,
    job_time_entry_id CHAR(36) NOT NULL,
    executed_by_user_id CHAR(36) NOT NULL,

    executed_at DATETIME(6) NOT NULL,

    INDEX (checklist_item_id),
    INDEX (job_time_entry_id),
    INDEX (executed_by_user_id)
);

-- =====================================================================
-- 2) QUOTES (PRESUPUESTOS)
-- =====================================================================

CREATE TABLE quotes (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    client_company_id CHAR(36) NOT NULL,

    title VARCHAR(255),
    notes TEXT,

    status ENUM('draft','sent','accepted','rejected','expired')
        NOT NULL DEFAULT 'draft',

    issued_at DATETIME(6) NULL,
    accepted_at DATETIME(6) NULL,
    rejected_at DATETIME(6) NULL,
    expired_at DATETIME(6) NULL,

    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (client_company_id),
    INDEX (status)
);

-- =====================================================================
-- 2.1) QUOTE_ITEMS
-- =====================================================================

CREATE TABLE quote_items (
    id CHAR(36) PRIMARY KEY,
    quote_id CHAR(36) NOT NULL,

    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,

    line_total DECIMAL(15,4) NOT NULL,

    position INT NOT NULL DEFAULT 0,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (quote_id)
);

-- =====================================================================
-- 3) SALES (VENTAS OPERATIVAS)
-- =====================================================================

CREATE TABLE sales (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    client_company_id CHAR(36) NOT NULL,

    status ENUM('draft','confirmed','cancelled')
        NOT NULL DEFAULT 'draft',

    sale_date DATE NOT NULL,
    currency VARCHAR(10) NOT NULL,

    confirmed_at DATETIME(6) NULL,
    cancelled_at DATETIME(6) NULL,
    cancelled_reason TEXT NULL,

    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (client_company_id),
    INDEX (status)
);

-- =====================================================================
-- 3.1) SALE_ITEMS
-- =====================================================================

CREATE TABLE sale_items (
    id CHAR(36) PRIMARY KEY,
    sale_id CHAR(36) NOT NULL,

    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,

    line_total DECIMAL(15,4) NOT NULL,

    position INT NOT NULL DEFAULT 0,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (sale_id)
);

-- =====================================================================
-- 4) PURCHASES (COMPRAS)
-- =====================================================================

CREATE TABLE purchases (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    provider_company_id CHAR(36) NOT NULL,

    status ENUM('draft','confirmed','cancelled')
        NOT NULL DEFAULT 'draft',

    purchase_date DATE NOT NULL,
    currency VARCHAR(10) NOT NULL,

    confirmed_at DATETIME(6) NULL,
    cancelled_at DATETIME(6) NULL,
    cancelled_reason TEXT NULL,

    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (provider_company_id),
    INDEX (status)
);

-- =====================================================================
-- 4.1) PURCHASE_ITEMS
-- =====================================================================

CREATE TABLE purchase_items (
    id CHAR(36) PRIMARY KEY,
    purchase_id CHAR(36) NOT NULL,

    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,

    line_total DECIMAL(15,4) NOT NULL,

    position INT NOT NULL DEFAULT 0,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (purchase_id)
);

-- =====================================================================
-- 5) INVOICES (DOCUMENTO OPERATIVO)
-- =====================================================================

CREATE TABLE invoices (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    client_company_id CHAR(36) NOT NULL,
    sale_id CHAR(36) NULL,

    status ENUM('draft','issued','voided')
        NOT NULL DEFAULT 'draft',

    invoice_date DATE NOT NULL,

    issued_at DATETIME(6) NULL,
    voided_at DATETIME(6) NULL,
    voided_reason TEXT NULL,

    total_amount DECIMAL(15,4) NOT NULL,

    deleted_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (client_company_id),
    INDEX (sale_id),
    INDEX (status)
);

-- =====================================================================
-- 5.1) INVOICE_ITEMS
-- =====================================================================

CREATE TABLE invoice_items (
    id CHAR(36) PRIMARY KEY,
    invoice_id CHAR(36) NOT NULL,

    description VARCHAR(255) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    unit_price DECIMAL(15,4) NOT NULL,

    line_total DECIMAL(15,4) NOT NULL,

    position INT NOT NULL DEFAULT 0,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (invoice_id)
);

-- =====================================================================
-- 6) RECEIPTS (COBROS)
-- =====================================================================

CREATE TABLE receipts (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    client_company_id CHAR(36) NOT NULL,
    invoice_id CHAR(36) NULL,

    status ENUM('pending','completed','reversed')
        NOT NULL DEFAULT 'pending',

    receipt_date DATE NOT NULL,
    amount DECIMAL(15,4) NOT NULL,

    completed_at DATETIME(6) NULL,
    reversed_at DATETIME(6) NULL,
    reversed_reason TEXT NULL,

    deleted_at DATETIME(6),
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (client_company_id),
    INDEX (invoice_id),
    INDEX (status)
);

-- =====================================================================
-- 7) PAYMENTS (PAGOS)
-- =====================================================================

CREATE TABLE payments (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    provider_company_id CHAR(36) NOT NULL,
    purchase_id CHAR(36) NULL,

    status ENUM('pending','completed','reversed')
        NOT NULL DEFAULT 'pending',

    payment_date DATE NOT NULL,
    amount DECIMAL(15,4) NOT NULL,

    completed_at DATETIME(6) NULL,
    reversed_at DATETIME(6) NULL,
    reversed_reason TEXT NULL,

    deleted_at DATETIME(6),
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (provider_company_id),
    INDEX (purchase_id),
    INDEX (status)
);

-- =====================================================================
-- 8) ADJUSTMENTS (Ajustes operativos genéricos)
-- =====================================================================

CREATE TABLE adjustments (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,

    target_entity_type VARCHAR(100) NOT NULL,
    target_entity_id CHAR(36) NOT NULL,

    status ENUM('draft','applied','cancelled') NOT NULL DEFAULT 'draft',

    reason TEXT NOT NULL,
    applied_at DATETIME(6) NULL,

    deleted_at DATETIME(6),
    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    INDEX (company_id),
    INDEX (target_entity_type),
    INDEX (target_entity_id)
);

-- =====================================================================
-- FIN DEL SCHEMA FASE 2
-- =====================================================================
