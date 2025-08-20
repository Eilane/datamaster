resource "azurerm_data_factory" "adf" {
  name                = "adfcfacilbr"
  location            = var.location
  resource_group_name = var.resource_group_name
}