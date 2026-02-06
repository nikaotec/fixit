-- Allow nullable equipment in executions for non-maintenance orders
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'checklist_executions'
        AND column_name = 'equipment_id'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE checklist_executions ALTER COLUMN equipment_id DROP NOT NULL;
    END IF;
END $$;
