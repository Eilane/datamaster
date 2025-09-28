# Databricks notebook source
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DateType
from pyspark.sql.functions import lit

# COMMAND ----------

ORI_LAYER = "raw"
DEST_LAYER = "bronze"
STORAGE = "datalakecfacilbr"

# COMMAND ----------

class ReceitaPJ:
    """
        Classe responsável pela ingestão dos dados públicos da Receita Federal
        relacionados a Pessoas Jurídicas (PJ) no lake corporativo.
    """

    def __init__(self, year_month: str):
        self.year_month = year_month
        self.schema_estabelecimentos = None 
        self.schema_motivo = None    
        self.location  = None
        self.df_raw_moti  = None
        self.df_estabelecimentos = None


    def _location(self):
        """
        Método _location
        Descrição: Defini a localização dos arquivos
        """
        self.location = f"abfss://{ORI_LAYER}@{STORAGE}.dfs.core.windows.net/unity/receitafederal/pj/{self.year_month}/"
        return self.location


    def mov_files(self):
        """
        Método mov_files
        Descrição: Realiza a movimentação dos arquivos para os seus respectivos diretórios"""

        location = self._location()
        
        patterns = {
        "MOTI": "motivo",
        "ESTABELE": "estabelecimentos"
        } 

        for file in dbutils.fs.ls(location):
            for key, folder in patterns.items():
                if (key in file.name.upper()) and file.size >0:
                    destino = f"{location}{folder}/{file.name}"
                    dbutils.fs.mv(file.path, destino,recurse=True)
                    print(f"Movido {file.name} → {destino}")

    
    def schemas(self):
        """
        Método schemas
        Descrição: Realiza a Definição dos Schemas"""
        self.schema_motivo = StructType([StructField("cod_moti", StringType(), True),
                                    StructField("ds_moti", StringType(), True),
                                                ])
        

        self.schema_estabelecimentos = StructType([
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

           
    def read_files(self):
        """
        Método read_files
        Descrição: Realiza a leitura dos arquivos"""
        self.schemas()

        self.df_raw_moti = (
            spark.read
                .option("header", "false")
                .option("delimiter", ";")
                .schema(self.schema_motivo)
                .csv(self.location+"motivo")
                .withColumn("ano_mes_carga", lit(self.year_month)))
        
        self.df_estabelecimentos = (
            spark.read
                .option("header", "false")
                .option("delimiter", ";")
                .schema(self.schema_estabelecimentos)
                .csv(self.location+"estabelecimentos")
                .withColumn("ano_mes_carga", lit(self.year_month)))
        
        return self.df_raw_moti, self.df_estabelecimentos
    

    def write_files(self):
        """
        Método write_files
        Escreve os arquivos lidos nas tabelas motivos e estabelecimentos
        """
        self.df_raw_moti.write.mode("append").saveAsTable("prd.b_ext_rf_empresas.motivo")
        self.df_estabelecimentos.write.mode("append").partitionBy("ano_mes_carga").saveAsTable("prd.b_ext_rf_empresas.estabelecimentos")


 