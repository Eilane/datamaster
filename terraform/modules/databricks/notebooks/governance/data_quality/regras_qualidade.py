# Databricks notebook source
# MAGIC %md
# MAGIC # Qualidade de Dados
# MAGIC
# MAGIC **Objetivo:**  
# MAGIC Registrar as **regras de qualidade** que devem ser aplicadas nas tabelas **Silver** e **Gold** para garantir a integridade e consistência dos dados.
# MAGIC
# MAGIC **Tabela:** `prd.governance.regras_qualidade`
# MAGIC
# MAGIC **Descrição:**  
# MAGIC - Centraliza todas as regras de validação de dados.  
# MAGIC - Permite auditoria e monitoramento da conformidade dos dados.  
# MAGIC
# MAGIC **Exemplo de uso:**  
# MAGIC - Validar campos obrigatórios (`NOT NULL`)  
# MAGIC - Calcular scores de qualidade por tabela e coluna

# COMMAND ----------

from pyspark.sql.types import StructType, StructField, StringType, DateType

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE TABLE IF NOT EXISTS prd.governance.regras_qualidade (
# MAGIC     tabela STRING COMMENT 'Nome da tabela  da regra',
# MAGIC     coluna STRING COMMENT 'Coluna que será validada',
# MAGIC     regra STRING COMMENT 'Expressão da regra de qualidade a ser aplicada',
# MAGIC     descricao STRING COMMENT 'Descrição da regra de qualidade',
# MAGIC     dt_ini STRING COMMENT 'Data de início de validade da regra',
# MAGIC     dt_fim STRING COMMENT 'Data de fim de validade da regra (se aplicável)',
# MAGIC     status STRING COMMENT 'Status da regra (ativo/inativo)'
# MAGIC ) USING DELTA

# COMMAND ----------

schema = StructType([
    StructField("tabela", StringType(), True),
    StructField("coluna", StringType(), True),
    StructField("regra", StringType(), True),
    StructField("descricao", StringType(), True),
    StructField("dt_ini", StringType(), True), 
    StructField("dt_fim", StringType(), True),
    StructField("status", StringType(), True)
])

df_rules = spark.createDataFrame([
    ("estabelecimentos", "cnpj_basico",              "col IS NOT NULL", "CNPJ básico não pode ser nulo", '2025-01-01', None, "ativo"),
    ("estabelecimentos", "cnpj_ordem",               "col IS NOT NULL", "Ordem do CNPJ não pode ser nulo",'2025-01-01', None, "ativo"),
    ("estabelecimentos", "cnpj_dv",                  "col IS NOT NULL", "Dígito do CNPJ não pode ser nulo",'2025-01-01', None, "ativo"),
    ("estabelecimentos", "situacao_cadastral",       "col IS NOT NULL", "Situação cadastral não poder ser nulo" , '2025-01-01', None, "ativo"),
    ("estabelecimentos", "cnpj_dv",                  "col IS NOT NULL", "Dígito do CNPJ não pode ser nulo",'2025-01-01', None, "ativo"),
    ("estabelecimentos", "motivo_situacao_cadastral","col IS NOT NULL", "Código do motivo não pode ser nulo",'2025-01-01', None, "ativo"),
    ("motivo",           "cod_moti",                 "col IS NOT NULL", "Código do motivo não pode ser nulo" ,'2025-01-01', None, "ativo"),
    ("motivo",           "ds_moti",                  "col IS NOT NULL", "Situação cadastral não poder ser nulo" , '2025-01-01', None, "ativo" ), 
    ("clientes_pj",      "cnpj",                     "col IS NOT NULL", "CNPJ não pode ser nulo", '2025-01-01', None, "ativo"),
    ("clientes_pj",      "cnpj",                     "length(col) = 14", "CNPJ deve conter exatamente 14 dígitos", '2025-01-01', None, "ativo"),
    ("clientes_pj",      "cnpj",                     "count_distinct(col) = count(col)", "CNPJ deve ser único na tabela", '2025-01-01', None, "ativo"),
    ("clientes_pj",      "data_atualizacao",         "col = max(col)", "Selecionar apenas os registros da última data de atualização", '2025-01-01', None, "ativo"),
    ("g_prospectos_credito", "nr_cnpj",              "length(col) = 14", "CNPJ deve conter exatamente 14 dígitos", '2025-01-01', None, "ativo"),
    ("g_prospectos_credito", "email", "col RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'", "Email deve ser válido", '2025-01-01', None, "ativo"),
    ("g_prospectos_credito", "nome_fantasia",   "col IS NOT NULL", "Nome Fantasia não pode ser nulo", '2025-01-01', None, "ativo"),
    ("g_prospectos_credito", "email",   "col IS NOT NULL", "E-mail não pode ser nulo", '2025-01-01', None, "ativo"),
    ("g_estabelecimentos",      "nr_cnpj",                     "col IS NOT NULL", "CNPJ não pode ser nulo", '2025-01-01', None, "ativo"),
   
    ("g_estabelecimentos", "nr_cnpj", "length(col) = 14", "CNPJ deve conter exatamente 14 dígitos", '2025-01-01', None, "ativo"),
    ("g_estabelecimentos",      "nr_cnpj",                     "col IS NOT NULL", "CNPJ não pode ser nulo", '2025-01-01', None, "ativo"),

    ("g_alerta_endereco_suspeito", "nr_cnpj", "length(col) = 14", "CNPJ deve conter exatamente 14 dígitos", '2025-01-01', None, "ativo"),
    ("g_alerta_endereco_suspeito",      "nr_cnpj",                     "col IS NOT NULL", "CNPJ não pode ser nulo", '2025-01-01', None, "ativo"),
    ("g_alerta_endereco_suspeito",      "endereco_completo",                     "col IS NOT NULL", "Endereço completo não pode ser nulo", '2025-01-01', None, "ativo"),
], schema=schema)

# COMMAND ----------

df_rules.write.mode("overwrite").saveAsTable("prd.governance.regras_qualidade")