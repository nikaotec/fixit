ALTER TABLE IF EXISTS checklist_executions
    ADD COLUMN IF NOT EXISTS report_url TEXT,
    ADD COLUMN IF NOT EXISTS report_hash TEXT;
