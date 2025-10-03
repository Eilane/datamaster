terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  
  databricks = {
    source = "databricks/databricks"
  }
}
}

# Configuração do Provider Microsoft Azure 
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
}
  }
  subscription_id =  "035f79b4-e335-4a2c-8b45-b0f0a2f9ca0a"
}