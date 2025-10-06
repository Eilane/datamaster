# Databricks notebook source
# MAGIC %md
# MAGIC # Criação das tabelas
# MAGIC **Objetivo:** importar os dados públicos da Receita (CNPJ) e criar as tabelas:
# MAGIC - `prd.g_cfacil_credito.g_estabelecimentos` — todos os estabelecimentos tratados.
# MAGIC - `prd.g_cfacil_credito.g_alerta_endereco_suspeito` — registros com problemas no endereço
# MAGIC
# MAGIC Modo: **OVERWRITE** (substitui conteúdo anterior).
# MAGIC

# COMMAND ----------

from pyspark.sql.functions import concat_ws, lit, count, countDistinct, col

# COMMAND ----------

# MAGIC %run /Workspace/sistemas/credfacil/governance/data_quality/data_quality.py

# COMMAND ----------

# MAGIC %run ./ddl-estabelecimentos.py

# COMMAND ----------

# Informações do dicionario da receita
df_sit_cadastral = spark.createDataFrame(
    [
        (1, "NULA"),
        (2, "ATIVA"),
        (3, "SUSPENSA"),
        (4, "INAPTA"),
        (8, "BAIXADA")
    ],
    ["situacao_cadastral", "descricao"]
)

# COMMAND ----------

df_motivo = spark.sql("""select cast(cod_moti as int) as motivo_situacao_cadastral,ds_moti from prd.s_rf_empresas.motivo""")

# COMMAND ----------

df_prospectos_credito = spark.sql("""
                SELECT
                CONCAT(cnpj_basico, cnpj_ordem, cnpj_dv) AS nr_cnpj,
                *
                FROM prd.s_rf_empresas.estabelecimentos
""")

# COMMAND ----------

df_gold_prospectos = (
    df_prospectos_credito.withColumn(
        "nr_cnpj",
        concat_ws(
            "",
            "cnpj_basico",
            "cnpj_ordem",
            "cnpj_dv"
        )
    ).withColumn(
        "endereco_completo",
        concat_ws(
            " ",
            "tipo_logradouro",
            "logradouro",
            lit(","),
            "numero",
            lit(","),
            "complemento",
            lit("-"),
            "bairro",
            lit("-"),
            "cep"
        )
    ).select(
        "nr_cnpj",
        "nome_fantasia",
        "situacao_cadastral",
        "data_situacao_cadastral",
        "motivo_situacao_cadastral",
        "cnae_fiscal_principal",
        "tipo_logradouro",
        "logradouro",
        "numero",
        "complemento",
        "bairro",
        "cep",
        "uf",
        "municipio",
        "ddd_1",
        "telefone_1",
        "ddd_2",
        "telefone_2",
        "ddd_fax",
        "fax",
        "email",
        "endereco_completo"
    )
)

# COMMAND ----------

df_final = df_gold_prospectos.join(df_sit_cadastral, on="situacao_cadastral", how="inner")\
                              .join(df_motivo, on="motivo_situacao_cadastral", how="left")\
                              .selectExpr(
                                        "nr_cnpj",
                                        "nome_fantasia",
                                        "data_situacao_cadastral",
                                        "descricao as situacao_cadastral",
                                        "ds_moti",
                                        "cnae_fiscal_principal",
                                        "tipo_logradouro",
                                        "logradouro",
                                        "numero",
                                        "complemento",
                                        "bairro",
                                        "cep",
                                        "uf",
                                        "municipio",
                                        "ddd_1",
                                        "telefone_1",
                                        "ddd_2",
                                        "telefone_2",
                                        "ddd_fax",
                                        "fax",
                                        "email",
                                        "endereco_completo", 
                                        "current_date as dat_ref_carga").dropDuplicates()

# COMMAND ----------

dq = DQ("g_estabelecimentos",df_final)
dq_alerta = DQ("g_alerta_endereco_suspeito",df_final)

# COMMAND ----------

df_g_estabelecimentos = dq.apply_rule()
df_g_estabelecimentos.write.mode("overwrite").format("delta").saveAsTable("prd.g_cfacil_credito.g_estabelecimentos")

# COMMAND ----------

g_alerta_endereco_suspeito = dq_alerta.apply_rule()

# COMMAND ----------

# Agrupa por endereço e conta quantos CNPJs distintos existem
df_endereco_count = (
    g_alerta_endereco_suspeito
    .groupBy("endereco_completo")
    .agg(
        countDistinct("nr_cnpj").alias("qtd_cnpjs")
    )
    .filter(col("qtd_cnpjs") > 1)
    .withColumn("suspeito", lit(True))
)


df_resultado_g_alerta_endereco_suspeito = (
    g_alerta_endereco_suspeito
    .join(df_endereco_count.select("endereco_completo", "qtd_cnpjs", "suspeito"),
          on="endereco_completo",
          how="inner")
    .selectExpr(
        "nr_cnpj",
        "nome_fantasia",
        "situacao_cadastral",
        "ds_moti",
        "qtd_cnpjs as qtd_cnpjs_cad_end", 
        "current_date as dat_ref_carga"
    )
)

# COMMAND ----------

df_resultado_g_alerta_endereco_suspeito.write.mode("overwrite").format("delta").saveAsTable("prd.g_cfacil_credito.g_alerta_endereco_suspeito")