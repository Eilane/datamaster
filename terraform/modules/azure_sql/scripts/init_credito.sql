-- ========================================
-- Criar schema 'credito' se não existir
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'credito')
BEGIN
    EXEC('CREATE SCHEMA credito');
    PRINT 'Schema credito criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Schema credito já existe.';
END
GO

-- ========================================
-- Criar tabela clientes_pj no schema credito
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id
               WHERE t.name = 'clientes_pj' AND s.name = 'credito')
BEGIN
    CREATE TABLE credito.clientes_pj (
        cliente_id INT IDENTITY(1,1) PRIMARY KEY,
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
        data_inclusao DATETIME DEFAULT GETDATE(),
        data_atualizacao DATETIME DEFAULT GETDATE()
    );

    -- Inicializa a tabela 
    INSERT INTO credito.clientes_pj (
     razao_social, nome_fantasia, cnpj, inscricao_estadual, inscricao_municipal,
    tipo_atividade, porte_empresa, situacao_cadastral, data_abertura, data_baixa) VALUES
    ('Ambev S.A.',                       'Ambev',           '07526557000100', NULL, NULL, 'Fabricação e comércio de bebidas',       'Grande Porte', 'Ativa', NULL, NULL),
    ('Petrobras (Petróleo Brasileiro S.A.)','Petrobras',      '33000167000101', NULL, NULL, 'Extração e refino de petróleo',          'Grande Porte', 'Ativa', NULL, NULL),
    ('VALE S.A.',                         'Vale',            '33592510000154', NULL, NULL, 'Mineração e extração de minerais',       'Grande Porte', 'Ativa', NULL, NULL),
    ('Gerdau S.A.',                       'Gerdau',          '33611500000119', NULL, NULL, 'Aços e siderurgia',                      'Grande Porte', 'Ativa', NULL, NULL),
    ('Natura &Co Holding S.A.',          'Natura',          '71673990000177', NULL, NULL, 'Cosméticos e produtos de beleza',        'Grande Porte', 'Ativa', NULL, NULL),
    ('WEG S.A.',                          'WEG',             '84429695000111', NULL, NULL, 'Fabricação de equipamentos elétricos',  'Grande Porte', 'Ativa', NULL, NULL),
    ('Magazine Luiza S.A.',               'Magalu',          '47960950000121', NULL, NULL, 'Varejo eletrônico e físico',             'Grande Porte', 'Ativa', NULL, NULL),
    ('Marfrig Global Foods S.A.', 'Marfrig', '03853896000140', NULL, NULL, 'Indústria de proteína animal', 'Grande Porte', 'Ativa', NULL, NULL),
    ('MRV Engenharia e Participações S.A.', 'MRV', '08343492000120', NULL, NULL, 'Incorporação e construção civil', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Multiplan Empreendimentos Imobiliários S.A.', 'Multiplan', '07816890000153', NULL, NULL, 'Desenvolvimento imobiliário e shopping centers', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Suzano S.A.', 'Suzano', '16604287000155', NULL, NULL, 'Papel e celulose', 'Grande Porte', 'Ativa', NULL, NULL),
    ('JBS S.A.', 'JBS', '02916265000160', NULL, NULL, 'Indústria de alimentos – carnes', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Braskem S.A.', 'Braskem', '42150397000105', NULL, NULL, 'Indústria petroquímica', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Cosan S.A.', 'Cosan', '17661487000106', NULL, NULL, 'Comércio e logística de combustíveis e açúcar', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Totvs S.A.', 'Totvs', '53113791000122', NULL, NULL, 'Desenvolvimento de software e soluções de TI', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Lojas Renner S.A.', 'Renner', '92754738000120', NULL, NULL, 'Varejo de moda e vestuário', 'Grande Porte', 'Ativa', NULL, NULL),
    ('Raia Drogasil S.A.', 'RD', '61585865000151', NULL, NULL, 'Rede de farmácias e serviços de saúde', 'Grande Porte', 'Ativa', NULL, NULL);

    PRINT 'Tabela clientes_pj criada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Tabela clientes_pj já existe.';
END
GO

-- ========================================
-- Criar tabela de controle de watermark
-- ========================================
IF NOT EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id
               WHERE t.name = 'control_watermark' AND s.name = 'credito')
BEGIN
    CREATE TABLE credito.control_watermark
    (
        id INT IDENTITY(1,1) PRIMARY KEY,
        ultima_atualizacao DATETIME NOT NULL
    );

    -- primeira carga full 
    INSERT INTO credito.control_watermark (ultima_atualizacao)
    VALUES ('1900-01-01');

    PRINT 'Tabela control_watermark criada e inicializada.';
END
ELSE
BEGIN
    PRINT 'Tabela control_watermark já existe.';
END
GO

-- ========================================
-- Criar procedure para atualizar watermark
-- ========================================
IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE type = 'P' 
      AND name = 'sp_update_watermark' 
      AND schema_id = SCHEMA_ID('credito')
)
BEGIN
    EXEC('
            CREATE PROCEDURE credito.sp_atualiza_watermark
            AS
            BEGIN
                SET NOCOUNT ON;
                INSERT INTO credito.control_watermark (ultima_atualizacao)
                VALUES (GETDATE());
            END
    ');
    PRINT 'Procedure credito.sp_update_watermark criada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Procedure credito.sp_update_watermark já existe.';
END
GO
