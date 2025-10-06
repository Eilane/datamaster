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

variable "meu_ip" {
  description = "Meu Ip para liberação de regras no banco"
  type        = string
  sensitive   = true
}