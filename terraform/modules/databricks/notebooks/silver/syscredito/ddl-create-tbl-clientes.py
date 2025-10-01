# Databricks notebook source
# MAGIC %sql
# MAGIC CREATE TABLE prd.b_cfacil_credito.clientes_pj (
# MAGIC     cliente_id BIGINT COMMENT "Identificador único do cliente PJ",
# MAGIC     razao_social STRING NOT NULL COMMENT "Razão social da empresa",
# MAGIC     nome_fantasia STRING COMMENT "Nome fantasia da empresa",
# MAGIC     cnpj STRING NOT NULL COMMENT "CNPJ da empresa (único)",
# MAGIC     inscricao_estadual STRING COMMENT "Inscrição estadual da empresa",
# MAGIC     inscricao_municipal STRING COMMENT "Inscrição municipal da empresa",
# MAGIC     tipo_atividade STRING COMMENT "Descrição da atividade principal",
# MAGIC     porte_empresa STRING COMMENT "Porte da empresa (ME, EPP, etc.)",
# MAGIC     situacao_cadastral STRING COMMENT "Situação cadastral conforme Receita Federal",
# MAGIC     data_abertura DATE COMMENT "Data de abertura da empresa",
# MAGIC     data_baixa DATE COMMENT "Data de baixa da empresa, se aplicável",
# MAGIC     data_inclusao TIMESTAMP  COMMENT "Data de inclusão do registro no sistema",
# MAGIC     data_atualizacao TIMESTAMP COMMENT "Data da última atualização do registro"
# MAGIC )
# MAGIC USING DELTA
# MAGIC COMMENT "Tabela de clientes pessoa jurídica da CrediFácil Brasil. Contém dados cadastrais integrados da Receita Federal e outras fontes públicas.";
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC INSERT INTO prd.b_cfacil_credito.clientes_pj  (
# MAGIC     cliente_id, razao_social, nome_fantasia, cnpj, inscricao_estadual, inscricao_municipal,
# MAGIC     tipo_atividade, porte_empresa, situacao_cadastral, data_abertura, data_baixa
# MAGIC ) VALUES
# MAGIC (1,'Ambev S.A.',                       'Ambev',           '07526557000100', NULL, NULL, 'Fabricação e comércio de bebidas',       'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (2,'Petrobras (Petróleo Brasileiro S.A.)','Petrobras',      '33000167000101', NULL, NULL, 'Extração e refino de petróleo',          'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (3,'VALE S.A.',                         'Vale',            '33592510000154', NULL, NULL, 'Mineração e extração de minerais',       'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (4,'JBS S.A.',                          'JBS',             '02916265000160', NULL, NULL, 'Indústria de alimentos (proteínas)',     'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (5,'Gerdau S.A.',                       'Gerdau',          '33611500000119', NULL, NULL, 'Aços e siderurgia',                      'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (6,'Natura &Co Holding S.A.',          'Natura',          '71673990000177', NULL, NULL, 'Cosméticos e produtos de beleza',        'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (7,'WEG S.A.',                          'WEG',             '84429695000111', NULL, NULL, 'Fabricação de equipamentos elétricos',  'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (8,'Magazine Luiza S.A.',               'Magalu',          '47960950000121', NULL, NULL, 'Varejo eletrônico e físico',             'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (9,'Magazine Luiza S.A.', 'Magalu', '47960950000121', NULL, NULL, 'Comércio varejista de produtos eletrônicos e de consumo', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (10,'Marfrig Global Foods S.A.', 'Marfrig', '03853896000140', NULL, NULL, 'Indústria de proteína animal', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (11,'MRV Engenharia e Participações S.A.', 'MRV', '08343492000120', NULL, NULL, 'Incorporação e construção civil', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (12,'Multiplan Empreendimentos Imobiliários S.A.', 'Multiplan', '07816890000153', NULL, NULL, 'Desenvolvimento imobiliário e shopping centers', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (13,'Natura Cosméticos S.A.', 'Natura', '71673990000177', NULL, NULL, 'Cosméticos e produtos de beleza', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (14,'Suzano S.A.', 'Suzano', '16604287000155', NULL, NULL, 'Papel e celulose', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (15,'WEG S.A.', 'WEG', '84429695000111', NULL, NULL, 'Fabricação de equipamentos elétricos', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (16,'Gerdau S.A.', 'Gerdau', '33611500000119', NULL, NULL, 'Siderurgia e produtos de aço', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (17,'JBS S.A.', 'JBS', '02916265000160', NULL, NULL, 'Indústria de alimentos – carnes', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (18,'Ambev S.A.', 'Ambev', '07526557000100', NULL, NULL, 'Produção e comercialização de bebidas', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (19,'Braskem S.A.', 'Braskem', '42150397000105', NULL, NULL, 'Indústria petroquímica', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (29,'Cosan S.A.', 'Cosan', '17661487000106', NULL, NULL, 'Comércio e logística de combustíveis e açúcar', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (21,'Eletrobras Participações S.A.', 'Eletrobras', '011142651000188', NULL, NULL, 'Geração e transmissão de energia elétrica', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (22,'Totvs S.A.', 'Totvs', '53113791000122', NULL, NULL, 'Desenvolvimento de software e soluções de TI', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (23,'Lojas Renner S.A.', 'Renner', '92754738000120', NULL, NULL, 'Varejo de moda e vestuário', 'Grande Porte', 'Ativa', NULL, NULL),
# MAGIC (24,'Raia Drogasil S.A.', 'RD', '61585865000151', NULL, NULL, 'Rede de farmácias e serviços de saúde', 'Grande Porte', 'Ativa', NULL, NULL);