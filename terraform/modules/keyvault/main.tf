data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-credfacil"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

}

#Liberação do usuário logado no azure cli para criar,listar  e deletar secrets
resource "azurerm_key_vault_access_policy" "terraform_identity" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
  ]
}

# ----------------------------
# Secret no Key Vault
# ----------------------------
resource "azurerm_key_vault_secret" "senha_db" {
  name         = "database-sqlcfacilbr"
  value        = var.senha_db
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [ azurerm_key_vault_access_policy.terraform_identity ]
}

