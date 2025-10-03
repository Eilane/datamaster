variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização do recurso"
  type        = string
}

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
