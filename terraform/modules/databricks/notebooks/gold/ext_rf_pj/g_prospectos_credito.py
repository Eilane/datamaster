# Databricks notebook source
from pyspark.sql.functions import current_date, lit

# COMMAND ----------

# MAGIC %run ./ddl-create-tbl-prospectos.py

# COMMAND ----------

# MAGIC %run /Workspace/sistemas/credfacil/governance/data_quality/data_quality.py

# COMMAND ----------

df_prospectos_credito = spark.sql("""
                SELECT
                CONCAT(cnpj_basico, cnpj_ordem, cnpj_dv) AS nr_cnpj,
                nome_fantasia,
                email, 
                "Ativa" as status,
                data_situacao_cadastral
                FROM prd.s_rf_empresas.estabelecimentos
                where situacao_cadastral = 2 -- "Ativa" 
""")

# COMMAND ----------

dq = DQ("g_prospectos_credito",df_prospectos_credito)

# COMMAND ----------

df_prospectos_credito = dq.apply_rule()
df_prospectos_credito = df_prospectos_credito.withColumn(
    "dat_ref_carga",
    current_date()
)

df_prospectos_credito.write.mode("overwrite").saveAsTable("prd.g_cfacil_credito.g_prospectos_credito")