# Databricks notebook source
# MAGIC %md
# MAGIC # Atualização da Tabela Silver: `prd.s_cfacil_credito.clientes_pj`
# MAGIC **Empresa:** CrediFácil Brasil  
# MAGIC **Projeto:** Integração de Dados Públicos – Fase 1 Empresas  
# MAGIC **Caso de Uso:** Integração de Dados Clientes PJ
# MAGIC ---
# MAGIC **Objetivo do Notebook:**  
# MAGIC Atualizar a tabela **Silver** `s_cfacil_credito.clientes_pj` com os dados cadastrais de clientes PJ.

# COMMAND ----------

from pyspark.sql import Window
from pyspark.sql.functions import row_number, col

# COMMAND ----------

# MAGIC %run /Workspace/sistemas/credfacil/governance/data_quality/data_quality.py

# COMMAND ----------

tabela = "clientes_pj"

# COMMAND ----------

dq = DQ(tabela)

# COMMAND ----------

df_rules = (
    spark.table("prd.governance.regras_qualidade")
    .filter(
        (col("tabela") == tabela) &
        (col("status") == "ativo")
    )
)

# COMMAND ----------

df_clientes = spark.table("prd.b_cfacil_credito.clientes_pj")

# COMMAND ----------

df_clientes = dq.regra_is_not_null(df_rules,df_clientes)
df_clientes = dq.rule_cnpj(df_rules,df_clientes)
df_clientes.createOrReplaceTempView("vw_clientes_pj")

# COMMAND ----------

# MAGIC %sql
# MAGIC MERGE INTO prd.s_cfacil_credito.clientes_pj AS silver
# MAGIC USING vw_clientes_pj AS bronze
# MAGIC ON silver.cliente_id = bronze.cliente_id
# MAGIC WHEN MATCHED AND bronze.data_atualizacao > silver.data_atualizacao
# MAGIC THEN UPDATE SET
# MAGIC     razao_social = bronze.razao_social,
# MAGIC     nome_fantasia = bronze.nome_fantasia,
# MAGIC     cnpj = bronze.cnpj,
# MAGIC     inscricao_estadual = bronze.inscricao_estadual,
# MAGIC     inscricao_municipal = bronze.inscricao_municipal,
# MAGIC     tipo_atividade = bronze.tipo_atividade,
# MAGIC     porte_empresa = bronze.porte_empresa,
# MAGIC     situacao_cadastral = bronze.situacao_cadastral,
# MAGIC     data_abertura = bronze.data_abertura,
# MAGIC     data_baixa = bronze.data_baixa,
# MAGIC     data_inclusao = bronze.data_inclusao,
# MAGIC     data_atualizacao = bronze.data_atualizacao
# MAGIC WHEN NOT MATCHED
# MAGIC THEN INSERT (
# MAGIC     cliente_id,
# MAGIC     razao_social,
# MAGIC     nome_fantasia,
# MAGIC     cnpj,
# MAGIC     inscricao_estadual,
# MAGIC     inscricao_municipal,
# MAGIC     tipo_atividade,
# MAGIC     porte_empresa,
# MAGIC     situacao_cadastral,
# MAGIC     data_abertura,
# MAGIC     data_baixa,
# MAGIC     data_inclusao,
# MAGIC     data_atualizacao
# MAGIC ) VALUES (
# MAGIC     bronze.cliente_id,
# MAGIC     bronze.razao_social,
# MAGIC     bronze.nome_fantasia,
# MAGIC     bronze.cnpj,
# MAGIC     bronze.inscricao_estadual,
# MAGIC     bronze.inscricao_municipal,
# MAGIC     bronze.tipo_atividade,
# MAGIC     bronze.porte_empresa,
# MAGIC     bronze.situacao_cadastral,
# MAGIC     bronze.data_abertura,
# MAGIC     bronze.data_baixa,
# MAGIC     bronze.data_inclusao,
# MAGIC     bronze.data_atualizacao
# MAGIC );