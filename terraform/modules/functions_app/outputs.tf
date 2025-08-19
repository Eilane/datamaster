output "azurerm_service" {
  value = azurerm_service_plan.asprcemp.id
}

output "function_app" {
  value = azurerm_linux_function_app.funcrcemp.id
}