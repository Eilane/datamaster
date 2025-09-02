# Databricks Workspace Standard + System-assigned MI
resource "azurerm_databricks_workspace" "adb" {
  name                = "adb-cfacilbr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "trial"

  # Managed Identity:
  customer_managed_key_enabled  = true
}

# Role Assignment: dá permissão de Blob Data Contributor ao Databricks
resource "azurerm_role_assignment" "dbw_storage_contributor" {
  scope                =  var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_workspace.adb.identity[0].principal_id
}

# -------------------------------------------------
# Provider Databricks usando Managed Identity
# -------------------------------------------------
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.adb.id
  azure_use_msi              = true
}

# -------------------------------------------------
# Unity Catalog Metastore
# -------------------------------------------------
resource "databricks_metastore" "uc_metastore" {
  name         = "metastore_uc_cfacilbr"
  storage_root = "abfss:/governance@${var.storage_account_name}.dfs.core.windows.net/metastore/"
  region       = azurerm_databricks_workspace.adb.location
}

# -------------------------------------------------
# Associar Workspace ao Metastore
# -------------------------------------------------
resource "databricks_metastore_assignment" "assign_uc" {
  workspace_id = azurerm_databricks_workspace.adb.id
  metastore_id = databricks_metastore.uc_metastore.id
}

# -------------------------------------------------
# Cluster Single-Node
# -------------------------------------------------
resource "databricks_cluster" "single_node" {
  cluster_name            = "single-node-cluster"
  spark_version           = "13.2.x-scala2.12"
  node_type_id            = "Standard_D3_v2"
  autotermination_minutes = 30

  autoscale {
    min_workers = 1
    max_workers = 1
  }
}
