-- ========================================
-- Tabela: contato
-- ========================================
CREATE TABLE contato (
    contato_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes_pj(cliente_id) ON DELETE CASCADE,
    socio_id INT REFERENCES socio(socio_id) ON DELETE CASCADE,
    tipo_contato VARCHAR(50) NOT NULL, -- Ex: telefone, email, celular, whatsapp
    valor_contato VARCHAR(100) NOT NULL,
    observacao TEXT,
    data_inclusao TIMESTAMP DEFAULT NOW(),
    data_atualizacao TIMESTAMP DEFAULT NOW(),
    CONSTRAINT chk_cliente_ou_socio CHECK (
        (cliente_id IS NOT NULL AND socio_id IS NULL) OR
        (cliente_id IS NULL AND socio_id IS NOT NULL)
    )
);