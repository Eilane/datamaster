variable "senha_db" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}


variable "account_id" {
  description = "ID da sua conta Databricks"
  type        = string
  sensitive   = true
}

variable "meu_ip" {
  description = "Meu Ip para liberação de regras no banco"
  type        = string
  sensitive   = true
}