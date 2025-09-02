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
  name      = "credito"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# Configurações WAL / Replication
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


provider "postgresql" {
  host     = azurerm_postgresql_flexible_server.postgres.fqdn
  port     = 5432
  username = azurerm_postgresql_flexible_server.postgres.administrator_login
  password = azurerm_postgresql_flexible_server.postgres.administrator_password
  database = azurerm_postgresql_flexible_server_database.postgresdb.name 
  sslmode  = "require"
}

# resource "postgresql_schema" "clientes" {
#   name  = "clientes"
#   owner = azurerm_postgresql_flexible_server.postgres.administrator_password
# }

#Libera Ip do Firewall para acessar o Banco 
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_my_ip" {
  name             = "allow-my-ip"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "187.57.158.92"
  end_ip_address   = "187.57.158.92"
}


resource "null_resource" "clientes_pj_table" {
  provisioner "local-exec" {
    command = <<EOT
    PGPASSWORD=${azurerm_postgresql_flexible_server.postgres.administrator_password} psql -h ${azurerm_postgresql_flexible_server.postgres.fqdn} -U ${azurerm_postgresql_flexible_server.postgres.administrator_login} -d ${azurerm_postgresql_flexible_server_database.postgresdb.name} -f create_clientes_pj.sql
    EOT
  }
  depends_on = [postgresql_schema.clientes]
}
