
# Serverless
resource "azurerm_service_plan" "asprcemp" {
  name                = "asp-func-rcemp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_storage_account" "storage" {
  name                     = "stfuncflex123"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind                     = "StorageV2"
}

# Function App
resource "azurerm_linux_function_app" "funcrcemp" {
  name                = "funcreceitaemp"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id            = azurerm_service_plan.asprcemp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.12"
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
    "WEBSITES_INCLUDE_CLOUD_CERTS"       = "true"
  }
}


# resource "azurerm_role_assignment" "funcrcemp_storage" {
#   scope                = azurerm_storage_account.storage.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_linux_function_app.funcrcemp.identity[0].principal_id
# }

