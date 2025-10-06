# Databricks notebook source
# MAGIC %md
# MAGIC # Data Quality — Classe `DQ`
# MAGIC
# MAGIC ## Visão Geral
# MAGIC A classe **`DQ`** (Data Quality) implementa **validação de qualidade de dados** em DataFrames, com base em regras armazenadas na tabela (ex: `prd.governance.regras_qualidade`).
# MAGIC
# MAGIC O objetivo é permitir que equipes de engenharia e governança **centralizem regras de validação** e as apliquem automaticamente sobre diferentes tabelas sem necessidade de codificação manual por dataset.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## Estrutura Esperada da Tabela de Regras
# MAGIC
# MAGIC A tabela `prd.governance.regras_qualidade` armazena metadados das regras de Data Quality, incluindo:
# MAGIC - Nome da tabela e coluna alvo
# MAGIC - Expressão da regra em formato Spark SQL
# MAGIC - Descrição funcional da regra
# MAGIC - Período de validade (data inicial e final)
# MAGIC - Status de ativação
# MAGIC
# MAGIC
# MAGIC

# COMMAND ----------

from pyspark.sql.functions import lpad, col

# COMMAND ----------

# MAGIC %run ./regras_qualidade.py

# COMMAND ----------

# Classe principal de Data Quality
class DQ:
    """
    Classe de Data Quality para aplicar regras e gerar métricas de validação.
    """

    def __init__(self, nm_table, df_table):
        self.nm_table = nm_table
        self.df_table = df_table
        self.df_rules = None


    def filter_rules(self):
        df_rules = (
            spark.table("prd.governance.regras_qualidade")
            .filter((col("tabela") == self.nm_table) & (col("status") == "ativo"))
        )
        self.df_rules = df_rules
        return df_rules


    def regra_is_not_null(self):
        df_rules = self.df_rules.filter(self.df_rules.regra == "col IS NOT NULL")
        for row in df_rules.collect():
            coluna = row["coluna"]
            regra = row["regra"].replace("col", f"`{coluna}`")
            self.df_table = self.df_table.filter(regra)
        return self.df_table


    def rule_cnpj(self):
        df_rules = self.df_rules.filter(self.df_rules.regra == "length(col) = 14")
        for row in df_rules.collect():
            coluna = row["coluna"]
            self.df_table = self.df_table.withColumn(
                coluna, lpad(col(coluna).cast("string"), 14, "0")
            )
        return self.df_table



    def rule_email(self):
        df_rules = self.df_rules.filter(
            self.df_rules.regra
            == "col RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'"
        )
        for row in df_rules.collect():
            coluna = row["coluna"]
            regra = row["regra"].replace("col", f"`{coluna}`")
            self.df_table = self.df_table.filter(regra)
        return self.df_table



    def apply_rule(self):
        self.filter_rules()
        regras = [r["regra"] for r in self.df_rules.select("regra").distinct().collect()]

        for regra in regras:
            if regra == "col IS NOT NULL":
                self.df_table = self.regra_is_not_null()
            elif regra == "length(col) = 14":
                self.df_table = self.rule_cnpj()
            elif regra.startswith("col RLIKE"):
                self.df_table = self.rule_email()
        return self.df_table



    def validate_summary(self):
        self.filter_rules()

        results = []
        total = self.df_table.count()
        for row in self.df_rules.collect():
            coluna = row["coluna"]
            regra = row["regra"].replace("col", f"`{coluna}`")
            valid = self.df_table.filter(expr(regra)).count()
            pct_valid = round(valid / total * 100, 2) if total > 0 else 0
            results.append((coluna, row["regra"], pct_valid))

        return spark.createDataFrame(results, ["coluna", "regra", "percentual_valido"])
