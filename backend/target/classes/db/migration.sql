-- Migration script to fix cliente_id column type in equipamento table
-- This script converts the cliente_id foreign key from its current type to UUID

-- Step 1: Drop the existing foreign key constraint if it exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_equipamento_cliente' 
        AND table_name = 'equipamento'
    ) THEN
        ALTER TABLE equipamento DROP CONSTRAINT fk_equipamento_cliente;
    END IF;
END $$;

-- Step 2: Check if cliente_id column exists and needs conversion
DO $$
BEGIN
    -- If the column exists and is not already UUID type
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'equipamento' 
        AND column_name = 'cliente_id'
        AND data_type != 'uuid'
    ) THEN
        -- Drop the column (this will lose data, but since this is early development, it's acceptable)
        -- If you have important data, you'll need a more complex migration
        ALTER TABLE equipamento DROP COLUMN cliente_id;
        
        -- Add the column back as UUID type
        ALTER TABLE equipamento ADD COLUMN cliente_id UUID;
    END IF;
    
    -- If the column doesn't exist at all, create it
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'equipamento' 
        AND column_name = 'cliente_id'
    ) THEN
        ALTER TABLE equipamento ADD COLUMN cliente_id UUID;
    END IF;
END $$;

-- Step 3: Recreate the foreign key constraint
ALTER TABLE equipamento 
ADD CONSTRAINT fk_equipamento_cliente 
FOREIGN KEY (cliente_id) 
REFERENCES clientes(id);

-- Step 4: Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_equipamento_cliente_id ON equipamento(cliente_id);

-- Step 5: Add latitude and longitude columns
ALTER TABLE equipamento ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE equipamento ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Step 6: Add order type and problem description to maintenance orders
ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS order_type VARCHAR(20);
ALTER TABLE maintenance_orders ALTER COLUMN order_type SET DEFAULT 'MANUTENCAO';
UPDATE maintenance_orders SET order_type = 'MANUTENCAO' WHERE order_type IS NULL;

ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS problem_description TEXT;

-- Step 8: Add brand/model for non-maintenance orders
ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS equipment_brand VARCHAR(120);
ALTER TABLE maintenance_orders ADD COLUMN IF NOT EXISTS equipment_model VARCHAR(120);

-- Step 7: Allow nullable equipamento/checklist for non-maintenance orders
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
