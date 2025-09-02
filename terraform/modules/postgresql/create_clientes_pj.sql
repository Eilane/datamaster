
-- ========================================
-- Tabela: clientes_pj
-- ========================================

CREATE TABLE public.clientes_pj (
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

-- ========================================
-- Comentários nas colunas
-- ========================================
COMMENT ON COLUMN clientes_pj.cliente_id IS 'Identificador único do cliente';
COMMENT ON COLUMN clientes_pj.razao_social IS 'Razão social da empresa';
COMMENT ON COLUMN clientes_pj.nome_fantasia IS 'Nome fantasia da empresa';
COMMENT ON COLUMN clientes_pj.cnpj IS 'CNPJ da empresa, único';
COMMENT ON COLUMN clientes_pj.inscricao_estadual IS 'Inscrição estadual';
COMMENT ON COLUMN clientes_pj.inscricao_municipal IS 'Inscrição municipal';
COMMENT ON COLUMN clientes_pj.tipo_atividade IS 'Tipo de atividade econômica';
COMMENT ON COLUMN clientes_pj.porte_empresa IS 'Porte da empresa';
COMMENT ON COLUMN clientes_pj.situacao_cadastral IS 'Situação cadastral da empresa';
COMMENT ON COLUMN clientes_pj.data_abertura IS 'Data de abertura da empresa';
COMMENT ON COLUMN clientes_pj.data_baixa IS 'Data de baixa da empresa';
COMMENT ON COLUMN clientes_pj.data_inclusao IS 'Data de inclusão do registro';
COMMENT ON COLUMN clientes_pj.data_atualizacao IS 'Data da última atualização do registro';

