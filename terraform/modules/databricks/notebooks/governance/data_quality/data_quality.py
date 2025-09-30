# Databricks notebook source
from pyspark.sql.functions import lpad, col

# COMMAND ----------
class DQ:
    def __init__(self, nm_table):
        self.nm_table = nm_table
    

    def regra_is_not_null(self, df_rules, df_table):
        df_rules  = df_rules.filter(df_rules.regra == "col IS NOT NULL")
        for row in df_rules.collect():
            coluna = row["coluna"]
            regra = row["regra"].replace("col", f"`{coluna}`")

            df_table = df_table.filter(regra)
        return df_table

    
    def rule_cnpj(self, df_rules, df_table):
        df_rules  = df_rules.filter(df_rules.regra == "length(col) = 14")
        for row in df_rules.collect():
            coluna = row["coluna"]
            df_table = df_table.withColumn(
                coluna,
                lpad(col(coluna).cast("string"), 14, "0")
            )
        return df_table