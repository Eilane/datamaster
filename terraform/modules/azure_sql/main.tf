# -------------------------------------------------
# Azure SQL Server
# -------------------------------------------------
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlcfacilbr"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "15.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "cfacilbr@demo"
}

# -------------------------------------------------
# Azure SQL Database (Basic para manter custo baixo)
# -------------------------------------------------
resource "azurerm_mssql_database" "sql_db" {
  name                = "sqlcfacilbr"
  server_id           = azurerm_mssql_server.sql_server.id
  sku_name            = "Basic"
  max_size_gb         = 2
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant      = false
}

# -------------------------------------------------
# Firewall rule (opcional, permite seu IP acessar SQL)
# -------------------------------------------------
resource "azurerm_mssql_server_firewall_rule" "allow_my_ip" {
  name             = "allow_my_ip"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "187.57.158.92"
  end_ip_address   = "187.57.158.92"
}
