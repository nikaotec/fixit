CREATE TABLE IF NOT EXISTS favorite_technicians (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    technician_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_favorite_technician FOREIGN KEY (technician_id) REFERENCES users(id),
    CONSTRAINT uq_favorite_user_technician UNIQUE (user_id, technician_id)
);

CREATE INDEX IF NOT EXISTS idx_favorite_user_id ON favorite_technicians(user_id);
CREATE INDEX IF NOT EXISTS idx_favorite_technician_id ON favorite_technicians(technician_id);
