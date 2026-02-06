CREATE TABLE IF NOT EXISTS execution_photos (
    id BIGSERIAL PRIMARY KEY,
    checklist_execution_id BIGINT NOT NULL,
    url TEXT NOT NULL,
    mime_type TEXT,
    size_bytes BIGINT,
    hash_sha256 TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_exec_photo_execution FOREIGN KEY (checklist_execution_id) REFERENCES checklist_executions(id)
);

CREATE INDEX IF NOT EXISTS idx_exec_photo_execution_id ON execution_photos(checklist_execution_id);
