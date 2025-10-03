variable "senha_db" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Tenant ID da conta Azure"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Subscription ID da conta Azure"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "ID da sua conta Databricks"
  type        = string
  sensitive   = true
}