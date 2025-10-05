# Databricks notebook source
# MAGIC %md
# MAGIC # Atualização da Tabela Silver: `s_rf_empresas.motivo`
# MAGIC
# MAGIC **Empresa:** CrediFácil Brasil  
# MAGIC **Projeto:** Integração de Dados Públicos – Fase 1 Empresas  
# MAGIC **Caso de Uso:** Integração de Dados Clientes PJ
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC **Objetivo do Notebook:**  
# MAGIC Atualizar a tabela **Silver** `s_rf_empresas.motivo` com os dados mais recentes**.
# MAGIC

# COMMAND ----------

from pyspark.sql.functions import col

# COMMAND ----------

# MAGIC %run /Workspace/sistemas/credfacil/governance/data_quality/data_quality.py


# COMMAND ----------

# MAGIC %run ./ddl-create-table-silver.py


# COMMAND ----------

silver_motivo = spark.sql("""select cod_moti,
                                    ds_moti
                          from prd.b_ext_rf_empresas.motivo
                          where ano_mes_carga = (select max(ano_mes_carga) 
                                  from prd.b_ext_rf_empresas.motivo)""").dropDuplicates()


# COMMAND ----------
dq = DQ("motivo", silver_motivo)

# COMMAND ----------

df_final = dq.apply_rule()

# COMMAND ----------

df_final.write.format("delta").mode("overwrite").saveAsTable("prd.s_rf_empresas.motivo")