-- Migration to make documento column optional
ALTER TABLE clientes ALTER COLUMN documento DROP NOT NULL;
