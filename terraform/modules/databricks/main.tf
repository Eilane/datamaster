# Databricks Workspace Standard
resource "azurerm_databricks_workspace" "adb" {
  name                = "adb-cfacilbr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "trial"
}

# Databricks Access Connector com Managed Identity
resource "azurerm_databricks_access_connector" "adb_connector" {
  name                = "adb-connector"
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = "SystemAssigned"
  }
}

# Role Assignment: Blob Data Contributor
resource "azurerm_role_assignment" "dbw_storage_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.adb_connector.identity[0].principal_id
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
# Catálogo "credito"
# -------------------------------------------------
resource "databricks_catalog" "credito" {
  name        = "credito"
  comment     = "Catálogo para área de concessão de crédito"
  properties = {
  purpose    = "credit-operations"   # finalidades do catálogo
  owner_team = "squad-credito"       # equipe responsável
  sensitivity = "high"               # nível de sensibilidade dos dados
}
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


# -------------------------------------------------
# Criação dos schemas
# -------------------------------------------------


# -------------------------------------------------
# Schemas Bronze
# -------------------------------------------------
resource "databricks_schema" "b_rf_empresas" {
  name         = "b_rf_empresas"
  catalog_name = databricks_catalog.credito.name
  comment      = "[Bronze] Dados brutos da Receita Federal sobre empresas registradas"
}

resource "databricks_schema" "b_cfacil_credito" {
  name         = "b_cfacil_credito"
  catalog_name = databricks_catalog.credito.name
  comment      = "[Bronze] Dados brutos de clientes PJ do sistema de crédito da Crédito Fácil"
}

# -------------------------------------------------
# Schemas Silver
# -------------------------------------------------
resource "databricks_schema" "s_rf_empresas" {
  name         = "s_rf_empresas"
  catalog_name = databricks_catalog.credito.name
  comment      = "[Silver] Dados tratados e padronizados da Receita Federal sobre empresas registradas"
}

resource "databricks_schema" "s_cfacil_credito" {
  name         = "s_cfacil_credito"
  catalog_name = databricks_catalog.credito.name
  comment      = "[Silver] Dados tratados de clientes PJ da Crédito Fácil, com qualidade e consistência garantidas"
}

# -------------------------------------------------
# Schema Gold
# -------------------------------------------------
resource "databricks_schema" "g_cfacil_credito" {
  name         = "g_cfacil_credito"
  catalog_name = databricks_catalog.credito.name
  comment      = "[Gold] Camada de consumo consolidada com indicadores e métricas de crédito da Crédito Fácil"
}