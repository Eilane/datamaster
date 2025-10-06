variable "storage_account_id" {
  description = "ID Storage Account"
  type        = string
}

variable "storage_account_name" {
  description = "Nome Storage Account"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização do recurso"
  type        = string
}


variable "account_id" {
  description = "ID da sua conta Databricks"
  type        = string
  sensitive   = true
}


variable "subscription_id" {
  description = "Id subscription da Azure"
  type        = string
  sensitive   = true
}