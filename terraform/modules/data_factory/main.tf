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


# Linked Service Data Lake Gen2 no Data Factory
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "linked_gen2" {
  name            = "linked_gen2"
  data_factory_id = azurerm_data_factory.adf.id  

  url = "https://${var.storage_account_name}.dfs.core.windows.net/"

  # Managed Identity:
  use_managed_identity = true
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
    relative_url = "@dataset().base_url"
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
}

#####################PIPELINE##############

resource "azurerm_data_factory_pipeline" "pipeline_ingest_dados_pj" {
  name            = "pipeline_ingest_dados_pj"
  data_factory_id = azurerm_data_factory.adf.id


  parameters = {
            "year_month" = "YYYY-MM"
            }
  variables = { "year_month"= "YYYY-MM"
               "path" = "receitafederal/pj/"
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
                        "value": "@concat(\n    'https://funcaoreceita-gnhjdvb3bfcsbve6.westus2-01.azurewebsites.net/api/receitadadospj?year_month=',\n    variables('year_month')\n)",
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
            }
        ]
  JSON
}
  



# resource "azurerm_data_factory_trigger_schedule" "trigger_mensal" {
#   name            = "trigger_mensal"
#   data_factory_id = azurerm_data_factory.adf.id

#   frequency = "Month"
#   interval  = 1

#   start_time = "2025-08-13T21:16:00Z"
#   time_zone  = "UTC"

#   schedule {
#     minutes    = [0]
#     hours      = [9]
#     days_of_month = [-1] # -1 = último dia do mês
#   }

#   pipeline {
#     name = azurerm_data_factory_pipeline.pipeline_ingest_dados_pj.name

#     parameters = {
#       year_month = "0"
#     }
#   }
# }
