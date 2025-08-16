# Databricks notebook source
# MAGIC %md
# MAGIC # Projeto: Integração de Dados Clientes PJ

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Criação da Tabela Estabelecimentos
# MAGIC **Tabela:** `b_ext_rf_empresas.estabelecimentos`  
# MAGIC **Dataset:** Estabelecimento  
# MAGIC
# MAGIC **Descrição**:  
# MAGIC Tabela que contém informações públicas de empresas, com detalhes sobre cada estabelecimento, incluindo:  
# MAGIC - CNPJ  
# MAGIC - Nome da empresa  
# MAGIC - Endereço (logradouro, número, complemento, bairro, município, UF, CEP)  
# MAGIC - Telefone  
# MAGIC - Status do estabelecimento  
# MAGIC - Ano e mês da carga (`ano_mes_carga`)  
# MAGIC
# MAGIC **Origem dos Dados**  
# MAGIC [Receita Federal - Dados Abertos CNPJ](https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/)
# MAGIC
# MAGIC **Formato e Armazenamento**  
# MAGIC - Formato dos arquivos origem: CSV
# MAGIC - Tabela: Externa  
# MAGIC - Modo de carga: `append`  
# MAGIC
# MAGIC **Periodicidade de Carga**  
# MAGIC - Mensal
# MAGIC
# MAGIC **Observações**  
# MAGIC - Os dados são públicos e não requerem autenticação  
# MAGIC - A tabela é particionada por `ano_mes_carga` para otimização das consultas   
# MAGIC - Dados podem conter inconsistências, como telefones faltantes ou endereços incompletos, típicos de bases públicas
# MAGIC

# COMMAND ----------

from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DateType
from pyspark.sql.functions import lit

# COMMAND ----------

dbutils.widgets.text("year_month", "", "Ano-Mês (yyyy-MM)")
year_month = dbutils.widgets.get("year_month")

layer = "raw"
dest_layer = "bronze"
storage = "datalaketestedatamaster"
location = f"abfss://{layer}@{storage}.dfs.core.windows.net/receitafederal/pj/{year_month}/"
table_location = f"abfss://{dest_layer}@{storage}.dfs.core.windows.net/bronze/estabelecimentos/"

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Definição do schema da tabela

# COMMAND ----------

schema_estabelecimentos = StructType([
                                        StructField("cnpj_basico", StringType(), True),
                                        StructField("cnpj_ordem", StringType(), True),
                                        StructField("cnpj_dv", StringType(), True),
                                        StructField("identificador_matriz_filial", IntegerType(), True),
                                        StructField("nome_fantasia", StringType(), True),
                                        StructField("situacao_cadastral", IntegerType(), True),
                                        StructField("data_situacao_cadastral", DateType(), True),
                                        StructField("motivo_situacao_cadastral", IntegerType(), True),
                                        StructField("nome_cidade_exterior", StringType(), True),
                                        StructField("pais", IntegerType(), True),
                                        StructField("data_inicio_atividade", DateType(), True),
                                        StructField("cnae_fiscal_principal", IntegerType(), True),
                                        StructField("cnae_fiscal_secundaria", StringType(), True),
                                        StructField("tipo_logradouro", StringType(), True),
                                        StructField("logradouro", StringType(), True),
                                        StructField("numero", StringType(), True),
                                        StructField("complemento", StringType(), True),
                                        StructField("bairro", StringType(), True),
                                        StructField("cep", StringType(), True),
                                        StructField("uf", StringType(), True),
                                        StructField("municipio", IntegerType(), True),
                                        StructField("ddd_1", StringType(), True),
                                        StructField("telefone_1", StringType(), True),
                                        StructField("ddd_2", StringType(), True),
                                        StructField("telefone_2", StringType(), True),
                                        StructField("ddd_fax", StringType(), True),
                                        StructField("fax", StringType(), True),
                                        StructField("email", StringType(), True),
                                        StructField("situacao_especial", StringType(), True),
                                        StructField("data_situacao_especial", DateType(), True)
])

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Criação do Data Frame Estabelecimentos

# COMMAND ----------

df_estabelecimentos = (
    spark.read
         .option("header", "false")          
         .option("delimiter", ";")           
         .schema(schema_estabelecimentos)   
         .csv(location)
         .withColumn("ano_mes_carga", lit(year_month))  
)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Gravação dos dados na tabela

# COMMAND ----------

df_estabelecimentos.write.mode("append").partitionBy("ano_mes_carga").option("path", f"{table_location}").saveAsTable("b_ext_rf_empresas.estabelecimentos")