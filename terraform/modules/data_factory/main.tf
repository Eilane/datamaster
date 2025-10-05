data "azurerm_client_config" "current" {}

resource "azurerm_data_factory" "adf" {
  name                = "adfcfacilbr"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

# Role Assignment: dá permissão de Blob Data Contributor 
resource "azurerm_role_assignment" "dbw_storage_contributor" {
  scope                =  var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.adf.identity[0].principal_id
}



#Necessidade de subida via Arm template devido a falta de um recurso Nativo para link Http 
resource "azurerm_resource_group_template_deployment" "http_link" {
  name                = "httpLinkedServiceDeployment"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.DataFactory/factories/linkedservices",
      "apiVersion": "2018-06-01",
      "name": "[concat('${azurerm_data_factory.adf.name}', '/link_http')]",
      "properties": {
        "description": "Linked service HTTP criado via Terraform",
        "parameters": {
          "base_url": {
            "type": "String",
            "defaultValue": "https://"
          }
        },
        "type": "HttpServer",
        "typeProperties": {
          "url": "@{linkedService().base_url}",
          "enableServerCertificateValidation": true,
          "authenticationType": "Anonymous"
        }
      }
    }
  ]
}
TEMPLATE
}


# Linked Service Data Lake Gen2 no Data Factory
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "linked_gen2" {
  name            = "linked_gen2"
  data_factory_id = azurerm_data_factory.adf.id  

  url = "https://${var.storage_account_name}.dfs.core.windows.net/"

  # Managed Identity:
  use_managed_identity = true
}


#####################DATASETS##############

resource "azurerm_data_factory_dataset_binary" "ds_binary_datalake" {
  name            = "ds_binary_datalake"
  data_factory_id = azurerm_data_factory.adf.id

  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.linked_gen2.name
  

  parameters = {
    folder_raw = "string"
  }

 azure_blob_storage_location {
   container = "raw"
   path = "@dataset().folder_raw"
 }
}



resource "azurerm_data_factory_dataset_binary" "ds_binary_http" {
  name            = "ds_binary_http"
  data_factory_id = azurerm_data_factory.adf.id

  linked_service_name = "link_http"
  http_server_location {
    relative_url = "empresas"
    path = "dadoscnpj"
    filename = "estabelecimentos" 
    }
  # parâmetros do dataset
  parameters = {
    base_url = "https://"
  }

  compression {
    type  = "ZipDeflate"
    level = "Fastest"
  }

depends_on = [
    azurerm_resource_group_template_deployment.http_link
  ]
}



# ---------------------------------------------
# Linked Service Databricks no Azure Data Factory
# ---------------------------------------------
resource "azurerm_data_factory_linked_service_azure_databricks" "linked_adb" {
  name                = "linked_adb"
  data_factory_id     = azurerm_data_factory.adf.id
  description     = "ADB Linked Service via MSI"
  adb_domain      = var.databricks_workspace_url

  existing_cluster_id = var.databricks_cluster_id
  msi_work_space_resource_id = var.databricks_workspace_id

}


#####################PIPELINEs##############

resource "azurerm_data_factory_pipeline" "pipeline_ingest_lake" {
  name            = "pipeline_ingest_lake"
  data_factory_id = azurerm_data_factory.adf.id


  parameters = {
            "year_month" = "YYYY-MM"
            }
			
  activities_json =<<JSON
[
              {
                "name": "ext_rf_pj_bronze",
                "type": "DatabricksNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebookPath": "/Workspace/sistemas/credfacil/bronze/ext_rf_pj/main.py",
                    "baseParameters": {
                        "year_month": {
                            "value": "@pipeline().parameters.year_month",
                            "type": "Expression"
                        }
                    }
                },
                "linkedServiceName": {
                    "referenceName": "linked_adb",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "ext_rf_pj_silver_motivo",
                "type": "DatabricksNotebook",
                "dependsOn": [
                    {
                        "activity": "ext_rf_pj_bronze",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebookPath": "/Workspace/sistemas/credfacil/silver/ext_rf_pj/motivo.py"
                },
                "linkedServiceName": {
                    "referenceName": "linked_adb",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "ext_rf_pj_silver_estabelecimentos",
                "type": "DatabricksNotebook",
                "dependsOn": [
                    {
                        "activity": "ext_rf_pj_bronze",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebookPath": "/Workspace/sistemas/credfacil/silver/ext_rf_pj/estabelecimentos.py"
                },
                "linkedServiceName": {
                    "referenceName": "linked_adb",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "ext_rf_pj_gold_g_prospectos_credito",
                "type": "DatabricksNotebook",
                "dependsOn": [
                    {
                        "activity": "ext_rf_pj_silver_motivo",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    },
                    {
                        "activity": "ext_rf_pj_silver_estabelecimentos",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebookPath": "/Workspace/sistemas/credfacil/gold/ext_rf_pj/g_prospectos_credito.py"
                },
                "linkedServiceName": {
                    "referenceName": "linked_adb",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "ext_rf_pj_gold_g_estabelecimentos",
                "type": "DatabricksNotebook",
                "dependsOn": [
                    {
                        "activity": "ext_rf_pj_gold_g_prospectos_credito",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebookPath": "/Workspace/sistemas/credfacil/gold/ext_rf_pj/g_estabelecimentos.py"
                },
                "linkedServiceName": {
                    "referenceName": "linked_adb",
                    "type": "LinkedServiceReference"
                }
            }
        ]
  JSON
}      


resource "azurerm_data_factory_pipeline" "pipeline_ingest_dados_pj" {
  name            = "pipeline_ingest_dados_pj"
  data_factory_id = azurerm_data_factory.adf.id
  
  depends_on = [
    azurerm_data_factory_pipeline.pipeline_ingest_lake

  ]

  parameters = {
            "year_month" = "YYYY-MM"
            }
  variables = { "year_month"= "YYYY-MM"
               "path" = "unity/receitafederal/pj/"
            }
      
  activities_json = <<JSON
[
            {
                "name": "GetZipUrls",
                "type": "WebActivity",
                "dependsOn": [
                    {
                        "activity": "clear year and month folder",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 3,
                    "retryIntervalInSeconds": 60,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "method": "GET",
                    "url": {
                        "value": "@concat(\n    'https://funcreceitaemp.azurewebsites.net/api/receitadadospj?year_month=',\n    variables('year_month')\n)",
                        "type": "Expression"
                    }
                }
            },
            {
                "name": "ForEach",
                "type": "ForEach",
                "dependsOn": [
                    {
                        "activity": "GetZipUrls",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "items": {
                        "value": "@json(activity('GetZipUrls').output.Response)",
                        "type": "Expression"
                    },
                    "batchCount": 10,
                    "activities": [
                        {
                            "name": "copy",
                            "description": "Extração de dados públicos de empresas da receita federal ",
                            "type": "Copy",
                            "dependsOn": [],
                            "policy": {
                                "timeout": "0.12:00:00",
                                "retry": 3,
                                "retryIntervalInSeconds": 60,
                                "secureOutput": false,
                                "secureInput": false
                            },
                            "userProperties": [],
                            "typeProperties": {
                                "source": {
                                    "type": "BinarySource",
                                    "storeSettings": {
                                        "type": "HttpReadSettings",
                                        "requestMethod": "GET"
                                    },
                                    "formatSettings": {
                                        "type": "BinaryReadSettings",
                                        "compressionProperties": {
                                            "type": "ZipDeflateReadSettings",
                                            "preserveZipFileNameAsFolder": false
                                        }
                                    }
                                },
                                "sink": {
                                    "type": "BinarySink",
                                    "storeSettings": {
                                        "type": "AzureBlobFSWriteSettings",
                                        "copyBehavior": {
                                            "value": "None",
                                            "type": "Expression"
                                        }
                                    }
                                },
                                "enableStaging": false
                            },
                            "inputs": [
                                {
                                    "referenceName": "ds_binary_http",
                                    "type": "DatasetReference",
                                    "parameters": {
                                        "base_url": {
                                            "value": "@item()",
                                            "type": "Expression"
                                        }
                                    }
                                }
                            ],
                            "outputs": [
                                {
                                    "referenceName": "ds_binary_datalake",
                                    "type": "DatasetReference",
                                    "parameters": {
                                        "folder_raw": {
                                            "value": "@concat(variables('path'),variables('year_month'))",
                                            "type": "Expression"
                                        }
                                    }
                                }
                            ]
                        }
                    ]
                }
            },
            {
                "name": "Set variable year_month",
                "type": "SetVariable",
                "dependsOn": [],
                "policy": {
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "variableName": "year_month",
                    "value": {
                        "value": "@if(\n        equals(pipeline().parameters.year_month, 'YYYY-MM'),\n        formatDateTime(utcNow(), 'yyyy-MM'),\n        pipeline().parameters.year_month\n    )",
                        "type": "Expression"
                    }
                }
            },
            {
                "name": "clear year and month folder",
                "type": "Delete",
                "dependsOn": [
                    {
                        "activity": "Set variable year_month",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "0.12:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "dataset": {
                        "referenceName": "ds_binary_datalake",
                        "type": "DatasetReference",
                        "parameters": {
                            "folder_raw": {
                                "value": "@concat(variables('path'),variables('year_month'))",
                                "type": "Expression"
                            }
                        }
                    },
                    "enableLogging": false,
                    "storeSettings": {
                        "type": "AzureBlobFSReadSettings",
                        "recursive": true,
                        "enablePartitionDiscovery": false
                    }
                }
            },
            {
                "name": "ingest_lake",
                "type": "ExecutePipeline",
                "dependsOn": [
                    {
                        "activity": "ForEach",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "pipeline": {
                        "referenceName": "pipeline_ingest_lake",
                        "type": "PipelineReference"
                    },
                    "waitOnCompletion": true,
                    "parameters": {
                        "year_month": {
                            "value": "@variables('year_month')",
                            "type": "Expression"
                        }
                    }
                }
            }
           
        ]
  JSON
}
  



resource "azurerm_data_factory_trigger_schedule" "trigger_mensal" {
  name            = "trigger_mensal"
  data_factory_id = azurerm_data_factory.adf.id

  frequency = "Month"
  interval  = 1

  start_time = "2025-08-13T21:16:00Z"
  time_zone  = "UTC"

  schedule {
    minutes    = [0]
    hours      = [9]
    days_of_month = [-1] # -1 = último dia do mês
  }

  pipeline {
    name = azurerm_data_factory_pipeline.pipeline_ingest_dados_pj.name

    parameters = {
      year_month = "0"
    }
  }
}


resource "azurerm_data_factory_linked_service_key_vault" "ls_kv" {
  name                = "linked_kv"
  data_factory_id     = azurerm_data_factory.adf.id
  key_vault_id        = var.azurerm_key_vault_id
}

# role de acesso
resource "azurerm_key_vault_access_policy" "adf_policy" {
  key_vault_id = var.azurerm_key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_data_factory.adf.identity[0].principal_id

  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "linked_sqldatabase" {
  name                = "linked_sqldatabase"
  data_factory_id     = azurerm_data_factory.adf.id

  connection_string = <<CONN
Server=tcp:sqlcfacilbr.database.windows.net,1433;
Database=sqlcfacilbr;
User ID=sqladmin;
CONN

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.ls_kv.name
    secret_name         = var.azurerm_key_vault_secret_name
  }
}



#Deployment do ARM template (pipeline CDC)
# resource "azurerm_resource_group_template_deployment" "cdc" {
#   name                = "cdcsql2"
#   resource_group_name = var.resource_group_name
#   deployment_mode     = "Incremental"

#   depends_on = [
#     azurerm_data_factory_linked_service_azure_sql_database.linked_sqldatabase
#   ]
#   template_content  = <<TEMPLATE
# {
#   "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
#   "contentVersion": "1.0.0.0",
#   "resources": [
# {
#     "type": "Microsoft.DataFactory/factories/adfcdcs",
#     "apiVersion": "2018-06-01",
#     "name": "[concat('${azurerm_data_factory.adf.name}', '/cfacilcdccredito')]",
#     "properties": {
#         "SourceConnectionsInfo": [
#             {
#                 "SourceEntities": [
#                     {
#                         "name": "credito.clientes_pj",
#                         "properties": {
#                             "schema": [],
#                             "dslConnectorProperties": [
#                                 {
#                                     "name": "schemaName",
#                                     "value": "credito"
#                                 },
#                                 {
#                                     "name": "tableName",
#                                     "value": "clientes_pj"
#                                 },
#                                 {
#                                     "name": "enableNativeCdc",
#                                     "value": true
#                                 },
#                                 {
#                                     "name": "netChanges",
#                                     "value": true
#                                 }
#                             ]
#                         }
#                     }
#                 ],
#                 "Connection": {
#                     "linkedService": {
#                         "referenceName": "linked_sqldatabase",
#                         "type": "LinkedServiceReference"
#                     },
#                     "linkedServiceType": "AzureSqlDatabase",
#                     "type": "linkedservicetype",
#                     "isInlineDataset": true,
#                     "commonDslConnectorProperties": [
#                         {
#                             "name": "allowSchemaDrift",
#                             "value": true
#                         },
#                         {
#                             "name": "inferDriftedColumnTypes",
#                             "value": true
#                         },
#                         {
#                             "name": "format",
#                             "value": "table"
#                         },
#                         {
#                             "name": "store",
#                             "value": "sqlserver"
#                         },
#                         {
#                             "name": "databaseType",
#                             "value": "databaseType"
#                         },
#                         {
#                             "name": "database",
#                             "value": "database"
#                         },
#                         {
#                             "name": "skipInitialLoad",
#                             "value": true
#                         }
#                     ]
#                 }
#             }
#         ],
#         "TargetConnectionsInfo": [
#             {
#                 "TargetEntities": [
#                     {
#                         "name": "raw/unity",
#                         "properties": {
#                             "schema": [],
#                             "dslConnectorProperties": [
#                                 {
#                                     "name": "container",
#                                     "value": "raw"
#                                 },
#                                 {
#                                     "name": "fileSystem",
#                                     "value": "raw"
#                                 },
#                                 {
#                                     "name": "folderPath",
#                                     "value": "unity"
#                                 }
#                             ]
#                         }
#                     }
#                 ],
#                 "Connection": {
#                     "linkedService": {
#                         "referenceName": "linked_gen2",
#                         "type": "LinkedServiceReference"
#                     },
#                     "linkedServiceType": "AzureBlobFS",
#                     "type": "linkedservicetype",
#                     "isInlineDataset": true,
#                     "commonDslConnectorProperties": [
#                         {
#                             "name": "allowSchemaDrift",
#                             "value": true
#                         },
#                         {
#                             "name": "inferDriftedColumnTypes",
#                             "value": true
#                         },
#                         {
#                             "name": "format",
#                             "value": "parquet"
#                         }
#                     ]
#                 },
#                 "DataMapperMappings": [
#                     {
#                         "targetEntityName": "raw/unity",
#                         "sourceEntityName": "credito.clientes_pj",
#                         "sourceConnectionReference": {
#                             "connectionName": "linked_sqldatabase",
#                             "type": "linkedservicetype"
#                         },
#                         "attributeMappingInfo": {
#                             "attributeMappings": []
#                         }
#                     }
#                 ],
#                 "Relationships": []
#             }
#         ],
#         "Policy": {
#             "recurrence": {
#                 "frequency": "Minute",
#                 "interval": 15
#             },
#             "mode": "Microbatch"
#         },
#         "allowVNetOverride": false
#     }
# }

#   ]
# }
# TEMPLATE

# }
