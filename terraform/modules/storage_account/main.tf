#Cria o Data Lake Gen 2
resource "azurerm_storage_account" "adls" {
  name                     = "datalakecfacilbr"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true" # Habilita Hierarchical Namespace (Data Lake Gen2)
}

# Cria container raw
resource "azurerm_storage_data_lake_gen2_filesystem" "fsraw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.adls.id
}

# Cria container bronze
resource "azurerm_storage_data_lake_gen2_filesystem" "fsbronze" {
  name               = "bronze"
  storage_account_id = azurerm_storage_account.adls.id
}

# Cria container silver
resource "azurerm_storage_data_lake_gen2_filesystem" "fssilver" {
  name               = "silver"
  storage_account_id = azurerm_storage_account.adls.id
}

# Cria container gold
resource "azurerm_storage_data_lake_gen2_filesystem" "fsgold" {
  name               = "gold"
  storage_account_id = azurerm_storage_account.adls.id
}

# Cria container  governance
resource "azurerm_storage_data_lake_gen2_filesystem" "fsgov" {
  name               = "governance"
  storage_account_id = azurerm_storage_account.adls.id
}