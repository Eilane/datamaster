resource "azurerm_data_factory" "adf" {
  name                = "adfcfacilbr"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Linked Service HTTP
resource "azurerm_data_factory_linked_service_web" "http_link" {
  name            = "link_http"
  data_factory_id = azurerm_data_factory.adf.id

  description = "Linked service HTTP criado via Terraform"

  # Parâmetro base_url
  parameters = {
    base_url = "https://"
  }
  url                           = "@{linkedService().base_url}"
  authentication_type           = "Anonymous"
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

resource "azurerm_data_factory_dataset_binary" "ds_binario_datalake" {
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

  linked_service_name = azurerm_data_factory_linked_service.link_http.name

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

  activities_json = file("${path.module}/pipeline_ingest_dados_pj.json")
}
