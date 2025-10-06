output "azurerm_data_factory_principal_id" {
  value = azurerm_data_factory.adf.identity[0].principal_id
}
