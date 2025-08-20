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
module "functions_app" {
  source = "./modules/functions_app"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  storage_account_name     = module.storage_account.storage_account_name
  primary_access_key       = module.storage_account.primary_access_key
}

# Criação do Data Factory
module "data_factory" {
  source = "./modules/data_factory"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação do AKS
module "aks" {
  source = "./modules/aks"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação do container registry
module "container_registry" {
  source = "./modules/container_registry"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação do event hub
module "event_hub" {
  source = "./modules/event_hub"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação do postgresql
module "postgresql" {
  source = "./modules/postgresql"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação do SPN

# Criação de roles