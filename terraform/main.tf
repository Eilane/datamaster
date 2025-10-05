


#Criação do Resource Group
module "resource_group" {
  source = "./modules/resource_group"
}


#Criação do Data Lake Gen 2
module "storage_account" {
  source = "./modules/storage_account"
  resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
  location                 = module.resource_group.azurerm_resource_group_rg_location
}

# Criação da função
module "functions_app" {
  source = "./modules/functions_app"
  resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
  location                 = module.resource_group.azurerm_resource_group_rg_location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id =   module.storage_account.storage_account_id
}


#Criação do Databricks
module "databricks" {
  source = "./modules/databricks"
  resource_group_name = module.resource_group.azurerm_resource_group_rg_name
  location =  module.resource_group.azurerm_resource_group_rg_location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id       = module.storage_account.storage_account_id
  account_id = var.account_id
}


# # SQL
# module "azure_sql" {
#   source = "./modules/azure_sql"
#   resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
#   location                 = module.resource_group.azurerm_resource_group_rg_location
#   senha_db = var.senha_db
#   meu_ip = var.meu_ip
# }


module "keyvault" {
  source = "./modules/keyvault"
  resource_group_name = module.resource_group.azurerm_resource_group_rg_name
  location = module.resource_group.azurerm_resource_group_rg_location
  senha_db = var.senha_db
  
}

# #Criação do Data Factory
module "data_factory" {
  source = "./modules/data_factory"
  resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
  location                 = module.resource_group.azurerm_resource_group_rg_location
  storage_account_name     = module.storage_account.storage_account_name
  storage_account_id       = module.storage_account.storage_account_id
  databricks_workspace_url = module.databricks.workspace_url
  databricks_workspace_id  = module.databricks.workspace_id
  databricks_cluster_id    = module.databricks.cluster_id
  azurerm_key_vault_id = module.keyvault.azurerm_key_vault_id
  azurerm_key_vault_secret_name = module.keyvault.azurerm_key_vault_secret_name  
  depends_on = [ module.databricks, module.keyvault ]
}  

################ EVENTOS ################

# # Criação do AKS
# module "aks" {
#   source = "./modules/aks"
#   resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
#   location                 = module.resource_group.azurerm_resource_group_rg_location
# }

# # Criação do container registry
# module "container_registry" {
#   source = "./modules/container_registry"
#   resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
#   location                 = module.resource_group.azurerm_resource_group_rg_location
# }

# # # Criação do event hub
# module "event_hub" {
#   source = "./modules/event_hub"
#   resource_group_name      = module.resource_group.azurerm_resource_group_rg_name
#   location                 = module.resource_group.azurerm_resource_group_rg_location
#   storage_account_id       = module.storage_account.storage_account_id
# }




