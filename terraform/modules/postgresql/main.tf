resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "postgrescfacilbr"
  resource_group_name = var.resource_group_name
  location            = var.location

#AJUSTAAAARR 
  administrator_login    = "cfacilbr"
  administrator_password = "cfacilbr@2025" 

  storage_mb = 32768              # 32 GB
  sku_name               = "GP_Standard_D4s_v3"
  version    = "12"              

  zone = "1"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

resource "azurerm_postgresql_flexible_server_database" "postgresdb" {
  name      = "db_clientes_pj"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}