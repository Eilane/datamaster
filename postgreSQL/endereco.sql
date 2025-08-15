-- ========================================
-- Tabela: endereco
-- ========================================
CREATE TABLE endereco (
    endereco_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES clientes_pj(cliente_id) ON DELETE CASCADE,
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),
    cep CHAR(8)
);
