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
  subscription_id = "035f79b4-e335-4a2c-8b45-b0f0a2f9ca0a"
}

# Criação do Grupo de Recurso  
resource "azurerm_resource_group" "rg" {
  name     = "rgprdcfacilbr"
  location = "westus2"
}


#Criação do Data Lake Gen 2
module "storage_account" {
  source = "./modules/storage_account"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
}

# Criação da função
# module "functions_app" {
#   source = "./modules/functions_app"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   storage_account_name     = module.storage_account.storage_account_name
#   storage_account_id =   module.storage_account.storage_account_id
# }

# #Criação do Data Factory
module "data_factory" {
  source = "./modules/data_factory"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id       = module.storage_account.storage_account_id
}


#Criação do Databricks
module "databricks" {
  source = "./modules/databricks"
  resource_group_name = azurerm_resource_group.rg.name
  location =  azurerm_resource_group.rg.location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id       = module.storage_account.storage_account_id
}

################ EVENTOS ################

# # Criação do AKS
# module "aks" {
#   source = "./modules/aks"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
# }

# # Criação do container registry
# module "container_registry" {
#   source = "./modules/container_registry"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
# }

# # # Criação do event hub
# module "event_hub" {
#   source = "./modules/event_hub"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   storage_account_id       = module.storage_account.storage_account_id
# }


# # SQL
# module "azure_sql" {
#   source = "./modules/azure_sql"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
# }


