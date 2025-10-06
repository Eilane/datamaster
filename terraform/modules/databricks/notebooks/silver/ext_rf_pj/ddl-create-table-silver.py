# Databricks notebook source
# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS  prd.s_rf_empresas.motivo(
# MAGIC     cod_moti STRING COMMENT 'Código do motivo',
# MAGIC     ds_moti  STRING COMMENT 'Descrição do motivo'    
# MAGIC )
# MAGIC USING DELTA
# MAGIC COMMENT 'Dados públicos de empresas da receita federal - Motivo do status da empresa';

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS prd.s_rf_empresas.estabelecimentos (
# MAGIC     cnpj_basico                STRING  COMMENT 'Raiz do CNPJ (8 primeiros dígitos)',
# MAGIC     cnpj_ordem                 STRING  COMMENT 'Ordem do CNPJ (4 dígitos após a raiz)',
# MAGIC     cnpj_dv                    STRING  COMMENT 'Dígito verificador do CNPJ',
# MAGIC     identificador_matriz_filial INT    COMMENT 'Identificador se é matriz (1) ou filial (2)',
# MAGIC     nome_fantasia              STRING  COMMENT 'Nome fantasia da empresa',
# MAGIC     situacao_cadastral         INT     COMMENT 'Situação cadastral do CNPJ',
# MAGIC     data_situacao_cadastral    DATE    COMMENT 'Data da situação cadastral',
# MAGIC     motivo_situacao_cadastral  INT     COMMENT 'Código do motivo da situação cadastral',
# MAGIC     nome_cidade_exterior       STRING  COMMENT 'Nome da cidade no exterior (se aplicável)',
# MAGIC     pais                       INT     COMMENT 'Código do país (se exterior)',
# MAGIC     data_inicio_atividade      DATE    COMMENT 'Data de início das atividades',
# MAGIC     cnae_fiscal_principal      INT     COMMENT 'Código CNAE fiscal principal',
# MAGIC     cnae_fiscal_secundaria     STRING  COMMENT 'Códigos CNAE fiscais secundários',
# MAGIC     tipo_logradouro            STRING  COMMENT 'Tipo de logradouro (Rua, Avenida, etc.)',
# MAGIC     logradouro                 STRING  COMMENT 'Nome do logradouro',
# MAGIC     numero                     STRING  COMMENT 'Número do endereço',
# MAGIC     complemento                STRING  COMMENT 'Complemento do endereço',
# MAGIC     bairro                     STRING  COMMENT 'Bairro',
# MAGIC     cep                        STRING  COMMENT 'CEP',
# MAGIC     uf                         STRING  COMMENT 'Unidade da Federação (sigla)',
# MAGIC     municipio                  INT     COMMENT 'Código do município (IBGE)',
# MAGIC     ddd_1                      STRING  COMMENT 'DDD do telefone principal',
# MAGIC     telefone_1                 STRING  COMMENT 'Telefone principal',
# MAGIC     ddd_2                      STRING  COMMENT 'DDD do telefone secundário',
# MAGIC     telefone_2                 STRING  COMMENT 'Telefone secundário',
# MAGIC     ddd_fax                    STRING  COMMENT 'DDD do fax',
# MAGIC     fax                        STRING  COMMENT 'Número do fax',
# MAGIC     email                      STRING  COMMENT 'Endereço de e-mail',
# MAGIC     situacao_especial          STRING  COMMENT 'Situação especial (se houver)',
# MAGIC     data_situacao_especial     DATE    COMMENT 'Data da situação especial',
# MAGIC     ano_mes_carga STRING COMMENT 'Ano e mês de referencia da carga'
# MAGIC )
# MAGIC USING DELTA
# MAGIC COMMENT 'Tabela de estabelecimentos da Receita Federal (CNPJs ativos e inativos)';