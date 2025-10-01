# Databricks notebook source
# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE prd.s_cfacil_credito.clientes_pj (
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