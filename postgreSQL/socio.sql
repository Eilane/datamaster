-- ========================================
-- Tabela: socio
-- ========================================
CREATE TABLE socio (
    socio_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes_pj(cliente_id) ON DELETE CASCADE,
    nome_socio VARCHAR(255) NOT NULL,
    cpf CHAR(11) NOT NULL,
    data_entrada DATE,
    participacao_percentual NUMERIC(5,2),
    data_inclusao TIMESTAMP DEFAULT NOW(),
    data_atualizacao TIMESTAMP DEFAULT NOW()
);
