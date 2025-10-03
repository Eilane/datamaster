# Databricks notebook source
# MAGIC %md
# MAGIC # Tabela de Captura de Dados CDC
# MAGIC
# MAGIC **Tabela:** `prd.b_cfacil_credito`  
# MAGIC **Localização no Data Lake:** `abfss://raw@datalakecfacilbr.dfs.core.windows.net/unity/credito.clientes_pj`  
# MAGIC
# MAGIC ## Descrição
# MAGIC Esta tabela armazena os dados de clientes PJ com suporte à captura de alterações (CDC).  
# MAGIC Ela é atualizada de forma incremental sempre que há mudanças no banco de dados de origem.
# MAGIC
# MAGIC

# COMMAND ----------

tabela = "prd.b_cfacil_credito.clientes_pj"
location = "abfss://raw@datalakecfacilbr.dfs.core.windows.net/unity/credito.clientes_pj/"

# COMMAND ----------

df_stream = (
    spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "parquet")
        .option("cloudFiles.schemaLocation", f"{location}clientes_pj/")
        .load(location)
)

# COMMAND ----------

query = (
    df_stream.writeStream
        .format("delta")
        .option("checkpointLocation", f"{location}/_checkpoint")
        .outputMode("append")
        .trigger(processingTime="1 minute") 
        .toTable(tabela)
)

query.awaitTermination()



