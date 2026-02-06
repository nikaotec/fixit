CREATE TABLE IF NOT EXISTS technician_reviews (
    id BIGSERIAL PRIMARY KEY,
    company_id UUID,
    technician_id BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    rating DOUBLE PRECISION NOT NULL,
    comment VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_review_company FOREIGN KEY (company_id) REFERENCES companies(id),
    CONSTRAINT fk_review_technician FOREIGN KEY (technician_id) REFERENCES users(id),
    CONSTRAINT fk_review_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_review_technician_id ON technician_reviews(technician_id);
CREATE INDEX IF NOT EXISTS idx_review_reviewer_id ON technician_reviews(reviewer_id);
