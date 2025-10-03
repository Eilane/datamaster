output "azurerm_key_vault_secret_name" {
  value = azurerm_key_vault_secret.senha_db.name
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.kv.id
}
