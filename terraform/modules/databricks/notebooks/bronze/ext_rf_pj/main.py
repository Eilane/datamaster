# Databricks notebook source
# MAGIC  %md
# MAGIC #Ingestão dos dados externos nas tabelas Estabelecimentos e Motivos
# MAGIC  **Tabelas:** `b_ext_rf_empresas.estabelecimentos`  `b_ext_rf_empresas.motivos`  
# MAGIC
# MAGIC  **Descrição**:  
# MAGIC  Tabela que contém informações públicas de empresas, com detalhes sobre cada estabelecimento, incluindo:  
# MAGIC  - CNPJ  
# MAGIC  - Nome da empresa  
# MAGIC  - Endereço (logradouro, número, complemento, bairro, município, UF, CEP)  
# MAGIC  - Telefone  
# MAGIC  - Status do estabelecimento  
# MAGIC  - Ano e mês da carga (`ano_mes_carga`)  
# MAGIC
# MAGIC  **Origem dos Dados**  
# MAGIC  [Receita Federal - Dados Abertos CNPJ](https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/)
# MAGIC
# MAGIC  **Formato e Armazenamento**  
# MAGIC  - Formato dos arquivos origem: CSV
# MAGIC  - Modo de carga: `append`  
# MAGIC
# MAGIC  **Periodicidade de Carga**  
# MAGIC  - Mensal
# MAGIC
# MAGIC  **Observações**  
# MAGIC  - A tabela é particionada por `ano_mes_carga` para otimização das consultas   
# MAGIC  - Dados podem conter inconsistências, como telefones faltantes ou endereços incompletos
# MAGIC

# COMMAND ----------

dbutils.widgets.text("year_month", "", "Ano-Mês (yyyy-MM)")
year_month = dbutils.widgets.get("year_month")

# COMMAND ----------

# MAGIC %run ./rec_pj.py

# COMMAND ----------

pj = ReceitaPJ(year_month)

# COMMAND ----------

print(ReceitaPJ.__doc__)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Movimentação dos Arquivos  
# MAGIC
# MAGIC - **Origem:** `Raw`  
# MAGIC - **Destino 1:** `Raw Estabelecimentos`  
# MAGIC - **Destino 2:** `Raw Motivos`  
# MAGIC

# COMMAND ----------

pj.mov_files()

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Leitura dos arquivos

# COMMAND ----------

pj.read_files()

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Escrita dos Dados 

# COMMAND ----------

pj.write_files()