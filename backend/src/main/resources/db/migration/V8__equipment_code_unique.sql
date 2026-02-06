CREATE UNIQUE INDEX IF NOT EXISTS ux_equipamento_company_codigo
ON equipamento(company_id, codigo)
WHERE codigo IS NOT NULL;
