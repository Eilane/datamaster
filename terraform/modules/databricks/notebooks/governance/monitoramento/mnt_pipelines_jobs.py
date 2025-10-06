# Databricks notebook source
from azure.identity import ManagedIdentityCredential
from azure.mgmt.datafactory import DataFactoryManagementClient
from datetime import datetime, timedelta, timezone
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, LongType, TimestampType
import os

# COMMAND ----------

SUBSCRIPTION_ID = os.environ['SUBSCRIPTION_ID']
RESOURCE_GROUP =  "rgprdcfacilbr"
FACTORY_NAME = "adfcfacilbr"
RESOURCE = "datafactory"

# COMMAND ----------

credential = ManagedIdentityCredential()
adf_client = DataFactoryManagementClient(credential, SUBSCRIPTION_ID)

start_time = end_time - timedelta(days=1)
end_time = datetime.now(timezone.utc)


# COMMAND ----------


schema = StructType([
    StructField('run_id', StringType(), True),
    StructField('pipeline_name', StringType(), True),
    StructField('status', StringType(), True),
    StructField('run_start', StringType(), True),
    StructField('run_end', StringType(), True),
    StructField('duration_in_ms', LongType(), True),
    StructField('parameters', StringType(), True),
    StructField('message', StringType(), True),
    StructField('source', StringType(), True)
])


pipeline_runs = adf_client.pipeline_runs.query_by_factory(
    resource_group_name=RESOURCE_GROUP,
    factory_name=FACTORY_NAME,
    filter_parameters={
        "lastUpdatedAfter": start_time.isoformat(),
        "lastUpdatedBefore": end_time.isoformat(),
    }
)
data = [
    (
        pipeline_run.run_id,
        pipeline_run.pipeline_name,
        pipeline_run.status,
        str(pipeline_run.run_start),
        str(pipeline_run.run_end),
        pipeline_run.duration_in_ms,
        pipeline_run.invoked_by,    
        pipeline_run.message,
        RESOURCE
    )
    for pipeline_run in pipeline_runs.value
]

# COMMAND ----------

df_spark = spark.createDataFrame(data, schema)

# COMMAND ----------

df_spark.createOrReplaceTempView("vw_pipeline_runs")

# COMMAND ----------

spark.sql("""
CREATE TABLE IF NOT EXISTS  prd.governance.mnt_pipelines_jobs (
  run_id STRING,
  pipeline_name STRING,
  status STRING,
  run_start STRING,
  run_end STRING,
  duration_in_ms BIGINT,
  parameters STRING,
  message STRING,
  source STRING
)
USING DELTA 
""")

# COMMAND ----------

spark.sql("""
MERGE INTO prd.governance.mnt_pipelines_jobs AS target
USING vw_pipeline_runs AS source
ON target.run_id = source.run_id
WHEN MATCHED THEN
  UPDATE SET
    target.pipeline_name = source.pipeline_name,
    target.status = source.status,
    target.run_start = source.run_start,
    target.run_end = source.run_end,
    target.duration_in_ms = source.duration_in_ms,
    target.parameters = source.parameters,
    target.message = source.message,
    target.source = source.source
WHEN NOT MATCHED THEN
  INSERT *
""")