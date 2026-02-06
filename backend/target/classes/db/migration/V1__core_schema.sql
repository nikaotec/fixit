CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    password TEXT NOT NULL,
    fcm_token TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    role TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    locale TEXT DEFAULT 'pt',
    company_id UUID
);

CREATE TABLE IF NOT EXISTS clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo TEXT NOT NULL,
    nome TEXT NOT NULL,
    documento TEXT UNIQUE,
    email TEXT,
    telefone TEXT,
    cep TEXT,
    rua TEXT,
    numero TEXT,
    bairro TEXT,
    cidade TEXT,
    estado TEXT,
    complemento TEXT,
    nome_contato TEXT,
    cargo_contato TEXT,
    notas_internas TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    company_id UUID
);

CREATE TABLE IF NOT EXISTS equipamento (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT,
    codigo TEXT,
    descricao TEXT,
    localizacao TEXT,
    qr_code TEXT,
    fabricante TEXT,
    modelo TEXT,
    numero_serie TEXT,
    classe_risco TEXT,
    geofence_radius_m INTEGER NOT NULL DEFAULT 100,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    cliente_id UUID,
    company_id UUID
);

CREATE TABLE IF NOT EXISTS checklist (
    id BIGSERIAL PRIMARY KEY,
    nome TEXT,
    descricao TEXT,
    company_id UUID,
    versao INTEGER NOT NULL DEFAULT 1,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS checklist_item (
    id BIGSERIAL PRIMARY KEY,
    descricao TEXT,
    ordem INTEGER,
    obrigatorio_foto BOOLEAN NOT NULL DEFAULT FALSE,
    critico BOOLEAN NOT NULL DEFAULT FALSE,
    checklist_id BIGINT
);

CREATE TABLE IF NOT EXISTS companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    cnpj TEXT UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE IF EXISTS users
    ADD COLUMN IF NOT EXISTS company_id UUID,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

ALTER TABLE IF EXISTS users
    ADD CONSTRAINT fk_users_company
    FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE IF EXISTS clientes
    ADD COLUMN IF NOT EXISTS company_id UUID;

ALTER TABLE IF EXISTS clientes
    ADD CONSTRAINT fk_clientes_company
    FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE IF EXISTS equipamento
    ADD COLUMN IF NOT EXISTS company_id UUID,
    ADD COLUMN IF NOT EXISTS fabricante TEXT,
    ADD COLUMN IF NOT EXISTS modelo TEXT,
    ADD COLUMN IF NOT EXISTS numero_serie TEXT,
    ADD COLUMN IF NOT EXISTS classe_risco TEXT,
    ADD COLUMN IF NOT EXISTS geofence_radius_m INTEGER NOT NULL DEFAULT 100;

ALTER TABLE IF EXISTS equipamento
    ADD CONSTRAINT fk_equipamento_company
    FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE IF EXISTS equipamento
    ADD CONSTRAINT fk_equipamento_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes(id);

ALTER TABLE IF EXISTS checklist
    ADD COLUMN IF NOT EXISTS company_id UUID,
    ADD COLUMN IF NOT EXISTS versao INTEGER NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE IF EXISTS checklist
    ADD CONSTRAINT fk_checklist_company
    FOREIGN KEY (company_id) REFERENCES companies(id);

ALTER TABLE IF EXISTS checklist_item
    ADD COLUMN IF NOT EXISTS critico BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE IF EXISTS checklist_item
    ADD CONSTRAINT fk_checklist_item_checklist
    FOREIGN KEY (checklist_id) REFERENCES checklist(id);

CREATE TABLE IF NOT EXISTS maintenance_orders (
    id BIGSERIAL PRIMARY KEY,
    company_id UUID NOT NULL,
    equipment_id BIGINT NOT NULL,
    client_id UUID,
    checklist_id BIGINT,
    creator_id BIGINT,
    technician_id BIGINT,
    status TEXT NOT NULL DEFAULT 'ABERTA',
    priority TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    scheduled_for TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    CONSTRAINT fk_mo_company FOREIGN KEY (company_id) REFERENCES companies(id),
    CONSTRAINT fk_mo_equipment FOREIGN KEY (equipment_id) REFERENCES equipamento(id),
    CONSTRAINT fk_mo_client FOREIGN KEY (client_id) REFERENCES clientes(id),
    CONSTRAINT fk_mo_checklist FOREIGN KEY (checklist_id) REFERENCES checklist(id),
    CONSTRAINT fk_mo_creator FOREIGN KEY (creator_id) REFERENCES users(id),
    CONSTRAINT fk_mo_technician FOREIGN KEY (technician_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS checklist_executions (
    id BIGSERIAL PRIMARY KEY,
    company_id UUID NOT NULL,
    maintenance_order_id BIGINT NOT NULL,
    equipment_id BIGINT NOT NULL,
    technician_id BIGINT NOT NULL,
    device_id TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    status TEXT NOT NULL,
    geo_lat DOUBLE PRECISION,
    geo_lng DOUBLE PRECISION,
    geo_accuracy DOUBLE PRECISION,
    geofence_ok BOOLEAN NOT NULL DEFAULT FALSE,
    integrity_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_ce_company FOREIGN KEY (company_id) REFERENCES companies(id),
    CONSTRAINT fk_ce_order FOREIGN KEY (maintenance_order_id) REFERENCES maintenance_orders(id),
    CONSTRAINT fk_ce_equipment FOREIGN KEY (equipment_id) REFERENCES equipamento(id),
    CONSTRAINT fk_ce_technician FOREIGN KEY (technician_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS checklist_execution_items (
    id BIGSERIAL PRIMARY KEY,
    checklist_execution_id BIGINT NOT NULL,
    checklist_item_id BIGINT NOT NULL,
    status BOOLEAN NOT NULL,
    observation TEXT,
    evidence_required BOOLEAN NOT NULL DEFAULT FALSE,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_cei_execution FOREIGN KEY (checklist_execution_id) REFERENCES checklist_executions(id),
    CONSTRAINT fk_cei_item FOREIGN KEY (checklist_item_id) REFERENCES checklist_item(id),
    CONSTRAINT uq_cei_execution_item UNIQUE (checklist_execution_id, checklist_item_id)
);

CREATE TABLE IF NOT EXISTS evidences (
    id BIGSERIAL PRIMARY KEY,
    checklist_execution_item_id BIGINT NOT NULL,
    url TEXT NOT NULL,
    hash_sha256 TEXT NOT NULL,
    mime_type TEXT,
    size_bytes BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_evidence_item FOREIGN KEY (checklist_execution_item_id) REFERENCES checklist_execution_items(id)
);

CREATE TABLE IF NOT EXISTS signatures (
    id BIGSERIAL PRIMARY KEY,
    checklist_execution_id BIGINT NOT NULL,
    signer_id BIGINT NOT NULL,
    signature_data TEXT NOT NULL,
    signature_hash TEXT NOT NULL,
    signed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_signature_execution FOREIGN KEY (checklist_execution_id) REFERENCES checklist_executions(id),
    CONSTRAINT fk_signature_signer FOREIGN KEY (signer_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    company_id UUID NOT NULL,
    actor_id BIGINT,
    action TEXT NOT NULL,
    entity TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    metadata TEXT,
    ip TEXT,
    user_agent TEXT,
    device_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_audit_company FOREIGN KEY (company_id) REFERENCES companies(id),
    CONSTRAINT fk_audit_actor FOREIGN KEY (actor_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS user_devices (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    device_id TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_user_device_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_user_device_user_device ON user_devices(user_id, device_id);

CREATE INDEX IF NOT EXISTS idx_users_company_id ON users(company_id);
CREATE INDEX IF NOT EXISTS idx_clientes_company_id ON clientes(company_id);
CREATE INDEX IF NOT EXISTS idx_equipamento_company_id ON equipamento(company_id);
CREATE INDEX IF NOT EXISTS idx_checklist_company_id ON checklist(company_id);
CREATE INDEX IF NOT EXISTS idx_mo_company_id ON maintenance_orders(company_id);
CREATE INDEX IF NOT EXISTS idx_mo_equipment_id ON maintenance_orders(equipment_id);
CREATE INDEX IF NOT EXISTS idx_mo_technician_id ON maintenance_orders(technician_id);
CREATE INDEX IF NOT EXISTS idx_mo_status_finished ON maintenance_orders(status, finished_at);
CREATE INDEX IF NOT EXISTS idx_mo_scheduled_for ON maintenance_orders(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_ce_company_id ON checklist_executions(company_id);
CREATE INDEX IF NOT EXISTS idx_ce_order_id ON checklist_executions(maintenance_order_id);
CREATE INDEX IF NOT EXISTS idx_ce_equipment_id ON checklist_executions(equipment_id);
CREATE INDEX IF NOT EXISTS idx_ce_technician_id ON checklist_executions(technician_id);
CREATE INDEX IF NOT EXISTS idx_ce_finished_at ON checklist_executions(finished_at);
CREATE INDEX IF NOT EXISTS idx_cei_execution_id ON checklist_execution_items(checklist_execution_id);
CREATE INDEX IF NOT EXISTS idx_evidence_item_id ON evidences(checklist_execution_item_id);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_logs(entity, entity_id);

CREATE OR REPLACE FUNCTION prevent_audit_log_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'audit_logs is append-only';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_logs_no_update ON audit_logs;
CREATE TRIGGER trg_audit_logs_no_update
    BEFORE UPDATE OR DELETE ON audit_logs
    FOR EACH ROW EXECUTE FUNCTION prevent_audit_log_modification();

CREATE OR REPLACE FUNCTION prevent_execution_modification_if_finalized()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.finished_at IS NOT NULL OR OLD.status = 'FINALIZED' THEN
        RAISE EXCEPTION 'checklist_executions finalized cannot be modified';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_execution_no_update ON checklist_executions;
CREATE TRIGGER trg_execution_no_update
    BEFORE UPDATE OR DELETE ON checklist_executions
    FOR EACH ROW EXECUTE FUNCTION prevent_execution_modification_if_finalized();

CREATE OR REPLACE FUNCTION prevent_execution_item_modification_if_finalized()
RETURNS TRIGGER AS $$
DECLARE
    v_finished_at TIMESTAMPTZ;
    v_status TEXT;
BEGIN
    SELECT finished_at, status INTO v_finished_at, v_status
    FROM checklist_executions
    WHERE id = OLD.checklist_execution_id;

    IF v_finished_at IS NOT NULL OR v_status = 'FINALIZED' THEN
        RAISE EXCEPTION 'checklist_execution_items cannot be modified after finalization';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_execution_items_no_update ON checklist_execution_items;
CREATE TRIGGER trg_execution_items_no_update
    BEFORE UPDATE OR DELETE ON checklist_execution_items
    FOR EACH ROW EXECUTE FUNCTION prevent_execution_item_modification_if_finalized();
