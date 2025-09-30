# Databricks notebook source
# MAGIC %md
# MAGIC # Atualização da Tabela Silver: `s_rf_empresas.estabelecimentos`
# MAGIC
# MAGIC **Empresa:** CrediFácil Brasil  
# MAGIC **Projeto:** Integração de Dados Públicos – Fase 1 Empresas  
# MAGIC **Caso de Uso:** Integração de Dados Clientes PJ
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC **Objetivo do Notebook:**  
# MAGIC Atualizar a tabela **Silver** `s_rf_empresas.estabelecimentos` com os dados mais recentes**.
# MAGIC

# COMMAND ----------

from pyspark.sql.functions import col

# COMMAND ----------

# MAGIC %run /Workspace/sistemas/credfacil/governance/data_quality/data_quality.py

# COMMAND ----------

dq = DQ("estabelecimentos")

# COMMAND ----------

df_rules = (
    spark.table("prd.governance.regras_qualidade")
    .filter(
        (col("tabela") == "estabelecimentos") &
        (col("status") == "ativo")
    )
)

# COMMAND ----------

silver_estabelecimentos = spark.sql("""select *
                                      from prd.b_ext_rf_empresas.estabelecimentos
                                      where ano_mes_carga = (select max(ano_mes_carga) 
                                  from prd.b_ext_rf_empresas.estabelecimentos)""").dropDuplicates()

# COMMAND ----------

df_final = dq.regra_is_not_null(df_rules,silver_estabelecimentos)

# COMMAND ----------

df_final.write.format("delta").mode("overwrite").saveAsTable("prd.s_rf_empresas.silver_estabelecimentos")