-- =====================================================================
--  SISA - ACCCORE (FASE 3)
--  SCHEMA CONTABLE • VERSION FINAL Y CONGELADA
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = "+00:00";


-- =====================================================================
-- 1) ACCOUNTING_ACCOUNTS (Plan de Cuentas)
-- =====================================================================

CREATE TABLE accounting_accounts (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,

    code VARCHAR(50) NOT NULL,           -- ej: 1.1.4
    name VARCHAR(255) NOT NULL,          -- Créditos por Ventas
    type ENUM('asset','liability','equity','income','expense') NOT NULL,

    parent_account_id CHAR(36) NULL,

    status ENUM('active','archived') NOT NULL DEFAULT 'active',
    archived_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    UNIQUE KEY uq_company_code (company_id, code),
    INDEX (company_id),
    INDEX (type),
    INDEX (parent_account_id)
);


-- =====================================================================
-- 2) ACCOUNTING_PERIODS (Periodos contables)
-- =====================================================================

CREATE TABLE accounting_periods (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,

    period_year INT NOT NULL,            -- Año: 2026
    period_month INT NOT NULL,           -- Mes: 1..12

    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    status ENUM('open','closed','reopened') NOT NULL DEFAULT 'open',

    closed_at DATETIME(6) NULL,
    reopened_at DATETIME(6) NULL,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    UNIQUE KEY uq_period (company_id, period_year, period_month),
    INDEX (company_id),
    INDEX (status)
);


-- =====================================================================
-- 3) ACCOUNTING_EVENTS (Eventos procesables)
-- =====================================================================

-- Estos NO se crean manualmente.
-- Son copias estructuradas de eventos ERP ya cerrados.

CREATE TABLE accounting_events (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,

    source_event_type VARCHAR(100) NOT NULL,    -- ej: invoice_issued
    source_event_id CHAR(36) NOT NULL,          -- id ERP
    event_date DATE NOT NULL,                   -- fecha operativa

    processed TINYINT(1) NOT NULL DEFAULT 0,    -- idempotencia
    processed_at DATETIME(6) NULL,

    payload JSON NOT NULL,                      -- datos necesarios
    metadata JSON NULL,

    created_at DATETIME(6) NOT NULL,

    UNIQUE KEY uq_event_unique (company_id, source_event_type, source_event_id),
    INDEX (company_id),
    INDEX (source_event_type),
    INDEX (event_date),
    INDEX (processed)
);


-- =====================================================================
-- 4) JOURNAL_ENTRIES (Asientos contables)
-- =====================================================================

CREATE TABLE journal_entries (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    accounting_period_id CHAR(36) NOT NULL,

    event_id CHAR(36) NOT NULL,        -- vínculo 1 a 1 con evento procesado

    entry_date DATE NOT NULL,          -- fecha contable

    status ENUM('posted','reversed') NOT NULL DEFAULT 'posted',

    reversed_by_entry_id CHAR(36) NULL, -- asiento espejo

    created_at DATETIME(6) NOT NULL,
    INDEX (company_id),
    INDEX (accounting_period_id),
    INDEX (event_id),
    INDEX (status),
    INDEX (entry_date)
);


-- =====================================================================
-- 5) JOURNAL_LINES (Debe / Haber)
-- =====================================================================

CREATE TABLE journal_lines (
    id CHAR(36) PRIMARY KEY,
    journal_entry_id CHAR(36) NOT NULL,
    account_id CHAR(36) NOT NULL,

    side ENUM('debit','credit') NOT NULL,
    amount DECIMAL(15,4) NOT NULL,

    currency VARCHAR(10) NOT NULL DEFAULT 'ARS',

    created_at DATETIME(6) NOT NULL,

    INDEX (journal_entry_id),
    INDEX (account_id),
    INDEX (side)
);


-- =====================================================================
-- 6) ACCOUNTING_REJECTIONS (Rechazos contables)
-- =====================================================================

CREATE TABLE accounting_rejections (
    id CHAR(36) PRIMARY KEY,
    event_id CHAR(36) NOT NULL,
    company_id CHAR(36) NOT NULL,

    reason TEXT NOT NULL,
    rejected_at DATETIME(6) NOT NULL,

    INDEX (event_id),
    INDEX (company_id)
);


-- =====================================================================
-- 7) LEDGER_BALANCES (Mayor contable — materializado)
--      *estructura derivada*
-- =====================================================================

CREATE TABLE ledger_balances (
    id CHAR(36) PRIMARY KEY,
    company_id CHAR(36) NOT NULL,
    accounting_period_id CHAR(36) NOT NULL,
    account_id CHAR(36) NOT NULL,

    opening_balance DECIMAL(15,4) NOT NULL DEFAULT 0,
    period_debit DECIMAL(15,4) NOT NULL DEFAULT 0,
    period_credit DECIMAL(15,4) NOT NULL DEFAULT 0,
    closing_balance DECIMAL(15,4) NOT NULL DEFAULT 0,

    created_at DATETIME(6) NOT NULL,
    updated_at DATETIME(6) NOT NULL,

    UNIQUE KEY uq_balance (company_id, accounting_period_id, account_id),
    INDEX (account_id),
    INDEX (accounting_period_id)
);


-- =====================================================================
-- FIN DEL SCHEMA FASE 3
-- =====================================================================
