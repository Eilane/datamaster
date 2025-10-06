# Databricks notebook source
# MAGIC %md
# MAGIC # Rotina de VACUUM das Tabelas 
# MAGIC
# MAGIC ## Objetivo
# MAGIC Executar o **VACUUM** em todas as tabelas gerenciadas pelo Unity Catalog para remover arquivos antigos do Delta Lake, liberar espaço e manter a performance das consultas.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Frequência
# MAGIC - **Semanal**
# MAGIC - **Dia:** Sábado
# MAGIC - **Horário:** 06:00

# COMMAND ----------

df_tables = spark.sql("""
SELECT table_catalog, table_schema, table_name
FROM system.information_schema.tables
WHERE table_catalog = "prd"
and table_type = 'MANAGED'
""")


# COMMAND ----------

for row in df_tables.collect():

    table_name = f"{row['table_catalog']}.{row['table_schema']}.{row['table_name']}"
    
    try:
        print(f"Executando o VACUUM {table_name}")
        spark.sql(f"VACUUM {table_name} RETAIN 168 HOURS") # 7 dias
    except Exception as e:
        print(f"Erro para executar o VACUUM para tabela{table_name}: {e}")