# Namespace do Event Hub
resource "azurerm_eventhub_namespace" "evhub" {
  name                = "evhubcfacilbr"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1
}


# Event Hub
resource "azurerm_eventhub" "nspj" {
  name                = "clientes_pj"
  namespace_id        = azurerm_eventhub_namespace.evhub.id 
  partition_count     = 2
  message_retention   = 1

  capture_description {
  enabled             = true
  encoding            = "Avro"
  interval_in_seconds = 300
  size_limit_in_bytes = 314572800

  destination {
    name                = "EventHubArchive.AzureBlockBlob"
    storage_account_id  = var.storage_account_id
    blob_container_name = "raw"
    archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
  }
  }
}

