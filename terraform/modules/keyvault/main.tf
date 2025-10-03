resource "azurerm_key_vault" "kv" {
  name                        = "kv-credfacil"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"

}


# ----------------------------
# Secret no Key Vault
# ----------------------------
resource "azurerm_key_vault_secret" "senha_db" {
  name         = "database-sqlcfacilbr"
  value        = var.senha_db
  key_vault_id = azurerm_key_vault.kv.id
}

