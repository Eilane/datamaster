# -------------------------------------------------
# Azure SQL Server
# -------------------------------------------------
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlcfacilbr"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.senha_db
}

# -------------------------------------------------
# Azure SQL Database 
# -------------------------------------------------
resource "azurerm_mssql_database" "sql_db" {
  name                = "sqlcfacilbr"
  server_id           = azurerm_mssql_server.sql_server.id
  sku_name            = "S3" 
  max_size_gb         = 2
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant      = false
}

# -------------------------------------------------
# Cria uma regra de firewall para permitir conexões de todos os serviços do Azure
# -------------------------------------------------
resource "azurerm_mssql_firewall_rule" "allow" {
  name             = "allow_ip"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


# -------------------------------------------------
# Meu Ip
# -------------------------------------------------
resource "azurerm_mssql_firewall_rule" "meuIp" {
  name             = "meuIp"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "186.213.133.71"
  end_ip_address   = "186.213.133.71"
}
