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
  subscription_id = var.subscription_id
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


#Criação do Databricks
module "databricks" {
  source = "./modules/databricks"
  resource_group_name = azurerm_resource_group.rg.name
  location =  azurerm_resource_group.rg.location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id       = module.storage_account.storage_account_id
  account_id = var.account_id
}


# # SQL
module "azure_sql" {
  source = "./modules/azure_sql"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  senha_db = var.senha_db
}


# #Criação do Data Factory
module "data_factory" {
  source = "./modules/data_factory"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id       = module.storage_account.storage_account_id
  databricks_workspace_url = module.databricks.workspace_url
  databricks_workspace_id  = module.databricks.workspace_id
  databricks_cluster_id    = module.databricks.cluster_id
  
}


module "keyvault" {
  source = "./modules/keyvault"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  tenant_id = var.tenant_id
  senha_db = var.senha_db
  azurerm_data_factory_id = module.data_factory.azurerm_data_factory_id
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




