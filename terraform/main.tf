terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configuração do Provider Microsoft Azure 
provider "azurerm" {
  features {}
}

# Criação do Grupo de Recurso 
resource "azurerm_resource_group" "rg" {
  name     = "rgprdcfacilbr"
  location = "West US 2"
}


# Criação do Data Lake Gen 2
module "storage_account" {
  source = "./modules/storage_account"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação do Data Lake Gen 2
module "functions" {
  source = "./modules/functions"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  storage_account_name     = azurerm_storage_account.adls.name
  primary_access_key       = azurerm_storage_account.adls.primary_access_key
}

