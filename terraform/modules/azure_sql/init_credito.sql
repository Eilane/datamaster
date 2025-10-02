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
--  Habilitar CDC no banco e na tabela
-- ========================================
-- Habilitar CDC no banco
IF NOT EXISTS (SELECT * FROM sys.databases d WHERE d.name = DB_NAME() AND d.is_cdc_enabled = 1)
BEGIN
    EXEC sys.sp_cdc_enable_db;
    PRINT 'CDC habilitado no banco.';
END
ELSE
BEGIN
    PRINT 'CDC já está habilitado no banco.';
END
GO

-- Habilitar CDC na tabela credito.clientes_pj
IF NOT EXISTS (SELECT * FROM cdc.change_tables ct
               JOIN sys.tables t ON ct.object_id = t.object_id
               JOIN sys.schemas s ON t.schema_id = s.schema_id
               WHERE t.name = 'clientes_pj' AND s.name = 'credito')
BEGIN
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'credito',
        @source_name   = N'clientes_pj',
        @role_name     = NULL;  -- ajustar role se necessário
    PRINT 'CDC habilitado na tabela clientes_pj.';
END
ELSE
BEGIN
    PRINT 'CDC já está habilitado na tabela clientes_pj.';
END
GO
