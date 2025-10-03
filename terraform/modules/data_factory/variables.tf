variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização do recurso"
  type        = string
}

variable "storage_account_name" {
  description = "Nome Storage Account"
  type        = string
}

variable "storage_account_id" {
  description = "ID Storage Account"
  type        = string
}


variable "databricks_workspace_url" {
  description = "Url do databricks"
  type        = string
}

variable "databricks_workspace_id" {
  description = "Id do databricks"
  type        = string
}

variable "databricks_cluster_id" {
  description = "Id do  cluster databricks"
  type        = string
}

variable "azurerm_key_vault_id" {
  description = "ID da Key Vault"
  type        = string
  sensitive   = true
}

variable "azurerm_key_vault_secret_name" {
  description = "Nome da Secret"
  type        = string
  sensitive   = true
}
