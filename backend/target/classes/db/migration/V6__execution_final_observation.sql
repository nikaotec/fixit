ALTER TABLE IF EXISTS checklist_executions
    ADD COLUMN IF NOT EXISTS final_observation TEXT;
