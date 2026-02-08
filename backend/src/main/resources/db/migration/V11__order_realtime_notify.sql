CREATE OR REPLACE FUNCTION notify_order_event(
    p_company_id UUID,
    p_order_id BIGINT,
    p_type TEXT
)
RETURNS void AS $$
BEGIN
    IF p_company_id IS NULL OR p_order_id IS NULL THEN
        RETURN;
    END IF;
    PERFORM pg_notify(
        'order_events',
        json_build_object(
            'type', p_type,
            'orderId', p_order_id,
            'companyId', p_company_id,
            'timestamp', now()
        )::text
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_order_event_from_execution(
    p_execution_id BIGINT,
    p_type TEXT
)
RETURNS void AS $$
DECLARE
    v_order_id BIGINT;
    v_company_id UUID;
BEGIN
    IF p_execution_id IS NULL THEN
        RETURN;
    END IF;
    SELECT maintenance_order_id, company_id INTO v_order_id, v_company_id
    FROM checklist_executions
    WHERE id = p_execution_id;
    PERFORM notify_order_event(v_company_id, v_order_id, p_type);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_orders_by_client(
    p_client_id UUID,
    p_type TEXT
)
RETURNS void AS $$
DECLARE
    r RECORD;
BEGIN
    IF p_client_id IS NULL THEN
        RETURN;
    END IF;
    FOR r IN
        SELECT id, company_id FROM maintenance_orders WHERE client_id = p_client_id
    LOOP
        PERFORM notify_order_event(r.company_id, r.id, p_type);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_orders_by_equipment(
    p_equipment_id BIGINT,
    p_type TEXT
)
RETURNS void AS $$
DECLARE
    r RECORD;
BEGIN
    IF p_equipment_id IS NULL THEN
        RETURN;
    END IF;
    FOR r IN
        SELECT id, company_id FROM maintenance_orders WHERE equipment_id = p_equipment_id
    LOOP
        PERFORM notify_order_event(r.company_id, r.id, p_type);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notify_orders_by_checklist(
    p_checklist_id BIGINT,
    p_type TEXT
)
RETURNS void AS $$
DECLARE
    r RECORD;
BEGIN
    IF p_checklist_id IS NULL THEN
        RETURN;
    END IF;
    FOR r IN
        SELECT id, company_id FROM maintenance_orders WHERE checklist_id = p_checklist_id
    LOOP
        PERFORM notify_order_event(r.company_id, r.id, p_type);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_notify_maintenance_orders()
RETURNS trigger AS $$
DECLARE
    v_company_id UUID;
    v_order_id BIGINT;
    v_type TEXT;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_company_id := OLD.company_id;
        v_order_id := OLD.id;
        v_type := 'order_deleted';
    ELSE
        v_company_id := NEW.company_id;
        v_order_id := NEW.id;
        v_type := 'order_updated';
    END IF;
    PERFORM notify_order_event(v_company_id, v_order_id, v_type);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_maintenance_orders ON maintenance_orders;
CREATE TRIGGER trg_notify_maintenance_orders
AFTER INSERT OR UPDATE OR DELETE ON maintenance_orders
FOR EACH ROW EXECUTE FUNCTION trg_notify_maintenance_orders();

CREATE OR REPLACE FUNCTION trg_notify_checklist_executions()
RETURNS trigger AS $$
DECLARE
    v_company_id UUID;
    v_order_id BIGINT;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_company_id := OLD.company_id;
        v_order_id := OLD.maintenance_order_id;
    ELSE
        v_company_id := NEW.company_id;
        v_order_id := NEW.maintenance_order_id;
    END IF;
    PERFORM notify_order_event(v_company_id, v_order_id, 'execution_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_checklist_executions ON checklist_executions;
CREATE TRIGGER trg_notify_checklist_executions
AFTER INSERT OR UPDATE OR DELETE ON checklist_executions
FOR EACH ROW EXECUTE FUNCTION trg_notify_checklist_executions();

CREATE OR REPLACE FUNCTION trg_notify_checklist_execution_items()
RETURNS trigger AS $$
DECLARE
    v_exec_id BIGINT;
BEGIN
    v_exec_id := COALESCE(NEW.checklist_execution_id, OLD.checklist_execution_id);
    PERFORM notify_order_event_from_execution(v_exec_id, 'execution_item_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_checklist_execution_items ON checklist_execution_items;
CREATE TRIGGER trg_notify_checklist_execution_items
AFTER INSERT OR UPDATE OR DELETE ON checklist_execution_items
FOR EACH ROW EXECUTE FUNCTION trg_notify_checklist_execution_items();

CREATE OR REPLACE FUNCTION trg_notify_evidences()
RETURNS trigger AS $$
DECLARE
    v_item_id BIGINT;
BEGIN
    v_item_id := COALESCE(NEW.checklist_execution_item_id, OLD.checklist_execution_item_id);
    IF v_item_id IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;
    PERFORM notify_order_event_from_execution(
        (SELECT checklist_execution_id FROM checklist_execution_items WHERE id = v_item_id),
        'execution_item_updated'
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_evidences ON evidences;
CREATE TRIGGER trg_notify_evidences
AFTER INSERT OR UPDATE OR DELETE ON evidences
FOR EACH ROW EXECUTE FUNCTION trg_notify_evidences();

CREATE OR REPLACE FUNCTION trg_notify_execution_photos()
RETURNS trigger AS $$
DECLARE
    v_exec_id BIGINT;
BEGIN
    v_exec_id := COALESCE(NEW.checklist_execution_id, OLD.checklist_execution_id);
    PERFORM notify_order_event_from_execution(v_exec_id, 'execution_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_execution_photos ON execution_photos;
CREATE TRIGGER trg_notify_execution_photos
AFTER INSERT OR UPDATE OR DELETE ON execution_photos
FOR EACH ROW EXECUTE FUNCTION trg_notify_execution_photos();

CREATE OR REPLACE FUNCTION trg_notify_signatures()
RETURNS trigger AS $$
DECLARE
    v_exec_id BIGINT;
BEGIN
    v_exec_id := COALESCE(NEW.checklist_execution_id, OLD.checklist_execution_id);
    PERFORM notify_order_event_from_execution(v_exec_id, 'execution_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_signatures ON signatures;
CREATE TRIGGER trg_notify_signatures
AFTER INSERT OR UPDATE OR DELETE ON signatures
FOR EACH ROW EXECUTE FUNCTION trg_notify_signatures();

CREATE OR REPLACE FUNCTION trg_notify_clientes()
RETURNS trigger AS $$
DECLARE
    v_client_id UUID;
BEGIN
    v_client_id := COALESCE(NEW.id, OLD.id);
    PERFORM notify_orders_by_client(v_client_id, 'order_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_clientes ON clientes;
CREATE TRIGGER trg_notify_clientes
AFTER INSERT OR UPDATE OR DELETE ON clientes
FOR EACH ROW EXECUTE FUNCTION trg_notify_clientes();

CREATE OR REPLACE FUNCTION trg_notify_equipamento()
RETURNS trigger AS $$
DECLARE
    v_equipment_id BIGINT;
BEGIN
    v_equipment_id := COALESCE(NEW.id, OLD.id);
    PERFORM notify_orders_by_equipment(v_equipment_id, 'order_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_equipamento ON equipamento;
CREATE TRIGGER trg_notify_equipamento
AFTER INSERT OR UPDATE OR DELETE ON equipamento
FOR EACH ROW EXECUTE FUNCTION trg_notify_equipamento();

CREATE OR REPLACE FUNCTION trg_notify_checklist()
RETURNS trigger AS $$
DECLARE
    v_checklist_id BIGINT;
BEGIN
    v_checklist_id := COALESCE(NEW.id, OLD.id);
    PERFORM notify_orders_by_checklist(v_checklist_id, 'order_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_checklist ON checklist;
CREATE TRIGGER trg_notify_checklist
AFTER INSERT OR UPDATE OR DELETE ON checklist
FOR EACH ROW EXECUTE FUNCTION trg_notify_checklist();

CREATE OR REPLACE FUNCTION trg_notify_checklist_item()
RETURNS trigger AS $$
DECLARE
    v_checklist_id BIGINT;
BEGIN
    v_checklist_id := COALESCE(NEW.checklist_id, OLD.checklist_id);
    PERFORM notify_orders_by_checklist(v_checklist_id, 'order_updated');
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_checklist_item ON checklist_item;
CREATE TRIGGER trg_notify_checklist_item
AFTER INSERT OR UPDATE OR DELETE ON checklist_item
FOR EACH ROW EXECUTE FUNCTION trg_notify_checklist_item();
