
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
  name                       = "func-rcemp"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.asprcemp.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

}