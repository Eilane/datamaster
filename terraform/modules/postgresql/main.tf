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
  name      = "clientes"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}


resource "azurerm_postgresql_flexible_server_configuration" "wal_level" {
  name                = "wal_level"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value               = "logical"
}

resource "azurerm_postgresql_flexible_server_configuration" "max_replication_slots" {
  name                = "max_replication_slots"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value               = "10"
}

resource "azurerm_postgresql_flexible_server_configuration" "max_wal_senders" {
  name                = "max_wal_senders"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value               = "10"
}
