
# Serverless
resource "azurerm_service_plan" "asprcemp" {
  name                = "asp-func-rcemp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Function App
resource "azurerm_linux_function_app" "funcrcemp" {
  name                = "funcreceitaemp"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.asprcemp.id
  storage_account_name = var.storage_account_name

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

resource "azurerm_role_assignment" "funcrcemp_storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.funcrcemp.identity[0].principal_id
}