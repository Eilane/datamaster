# Databricks notebook source
# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS prd.g_cfacil_credito.g_prospectos_credito (
# MAGIC                     nr_cnpj STRING COMMENT 'Número do CNPJ do prospecto',
# MAGIC                     nome_fantasia STRING COMMENT 'Nome fantasia da empresa prospectada',
# MAGIC                     email STRING COMMENT 'E-mail de contato da empresa',
# MAGIC                     status STRING COMMENT 'Status do prospecto (ativo, inativo, etc)',
# MAGIC                     data_situacao_cadastral DATE COMMENT 'Data da situação cadastral no cadastro nacional',
# MAGIC                     dat_ref_carga  DATE COMMENT 'Data de atualização da carga'
# MAGIC )
# MAGIC USING DELTA
# MAGIC ;