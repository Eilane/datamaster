-- ========================================
-- Tabela: clientes_pj
-- ========================================
CREATE TABLE clientes_pj (
    cliente_id SERIAL PRIMARY KEY,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj CHAR(14) NOT NULL UNIQUE,
    inscricao_estadual VARCHAR(50),
    inscricao_municipal VARCHAR(50),
    tipo_atividade VARCHAR(100),
    porte_empresa VARCHAR(50),
    situacao_cadastral VARCHAR(50),
    data_abertura DATE,
    data_baixa DATE,
    data_inclusao TIMESTAMP DEFAULT NOW(),
    data_atualizacao TIMESTAMP DEFAULT NOW()
);
