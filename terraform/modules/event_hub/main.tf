resource "azurerm_eventhub_namespace" "evhub" {
  name                = "evhubcfacilbr"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = 1
}