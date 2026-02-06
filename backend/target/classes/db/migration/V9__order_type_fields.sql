-- Add order type and problem fields
ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS order_type VARCHAR(20);
ALTER TABLE maintenance_orders ALTER COLUMN order_type SET DEFAULT 'MANUTENCAO';
UPDATE maintenance_orders SET order_type = 'MANUTENCAO' WHERE order_type IS NULL;

ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS problem_description TEXT;
ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS equipment_brand VARCHAR(120);
ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS equipment_model VARCHAR(120);

-- Allow nullable equipamento/checklist for non-maintenance orders
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'maintenance_orders'
        AND column_name = 'equipment_id'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE maintenance_orders ALTER COLUMN equipment_id DROP NOT NULL;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'maintenance_orders'
        AND column_name = 'checklist_id'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE maintenance_orders ALTER COLUMN checklist_id DROP NOT NULL;
    END IF;
END $$;
