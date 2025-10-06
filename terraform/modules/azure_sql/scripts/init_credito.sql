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
