# Databricks notebook source
# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS prd.g_cfacil_credito.g_alerta_endereco_suspeito (
# MAGIC     nr_cnpj STRING COMMENT 'Número do CNPJ da empresa',
# MAGIC     nome_fantasia STRING COMMENT 'Nome fantasia da empresa',
# MAGIC     situacao_cadastral STRING COMMENT 'Situação cadastral do CNPJ',
# MAGIC     ds_moti STRING COMMENT 'Descrição do motivo da suspeita',
# MAGIC     qtd_cnpjs_cad_end LONG COMMENT 'Quantidade de CNPJs cadastrados no mesmo Endereço',
# MAGIC     dat_ref_carga DATE COMMENT 'Data de referência da carga (gerada com current_date)'
# MAGIC )
# MAGIC USING DELTA
# MAGIC COMMENT 'Tabela que registra endereços com possíveis CNPJs suspeitos'

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS prd.g_cfacil_credito.g_estabelecimentos (
# MAGIC     nr_cnpj STRING COMMENT 'Número do CNPJ do estabelecimento',
# MAGIC     nome_fantasia STRING COMMENT 'Nome fantasia do estabelecimento',
# MAGIC     data_situacao_cadastral DATE COMMENT 'Data da situação cadastral',
# MAGIC     situacao_cadastral STRING COMMENT 'Descrição da situação cadastral',
# MAGIC     ds_moti STRING COMMENT 'Motivo da situação cadastral',
# MAGIC     cnae_fiscal_principal INT COMMENT 'CNAE fiscal principal do estabelecimento',
# MAGIC     tipo_logradouro STRING COMMENT 'Tipo de logradouro (Rua, Avenida, etc.)',
# MAGIC     logradouro STRING COMMENT 'Nome do logradouro',
# MAGIC     numero STRING COMMENT 'Número do endereço',
# MAGIC     complemento STRING COMMENT 'Complemento do endereço',
# MAGIC     bairro STRING COMMENT 'Bairro do endereço',
# MAGIC     cep STRING COMMENT 'CEP do endereço',
# MAGIC     uf STRING COMMENT 'Unidade federativa',
# MAGIC     municipio STRING COMMENT 'Município do endereço',
# MAGIC     ddd_1 STRING COMMENT 'DDD do telefone principal',
# MAGIC     telefone_1 STRING COMMENT 'Telefone principal',
# MAGIC     ddd_2 STRING COMMENT 'DDD do telefone secundário',
# MAGIC     telefone_2 STRING COMMENT 'Telefone secundário',
# MAGIC     ddd_fax STRING COMMENT 'DDD do fax',
# MAGIC     fax STRING COMMENT 'Número de fax',
# MAGIC     email STRING COMMENT 'E-mail de contato do estabelecimento',
# MAGIC     endereco_completo STRING COMMENT 'Endereço completo concatenado',
# MAGIC     dat_ref_carga DATE COMMENT 'Data de referência da carga (gerada com current_date)'
# MAGIC )
# MAGIC USING DELTA
# MAGIC COMMENT 'Tabela de estabelecimentos — dados cadastrais e de contato das empresas'
# MAGIC ;
# MAGIC