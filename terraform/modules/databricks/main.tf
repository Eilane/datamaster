
# Databricks Workspace Standard
resource "azurerm_databricks_workspace" "adb" {
  name                = "adb-cfacilbr"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "premium"
  public_network_access_enabled = true
  tags = {
    Environment = "prd"
  }
}

# -------------------------------------------------
# Provider Databricks
# ------------------------------------------------
provider "databricks" {
  host  = azurerm_databricks_workspace.adb.workspace_url
}

provider "databricks" {
  alias = "accounts"
  host  = "https://accounts.azuredatabricks.net"
  account_id =  var.account_id
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

# # -------------------------------------------------
# # Unity Catalog Metastore
# # -------------------------------------------------
resource "databricks_metastore" "unity" {
  name     = "metastore"
  storage_root = "abfss://governance@datalakecfacilbr.dfs.core.windows.net/metastore"
  region       = var.location
}


# Storage Credential
resource "databricks_storage_credential" "storage_cred" {
  name = "cred-unity"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.adb_connector.id
  }
}

resource "databricks_external_location" "ext_location_raw" {
  name            = "ext_raw_location_unity"
  url             = "abfss://raw@datalakecfacilbr.dfs.core.windows.net/unity"
  credential_name = databricks_storage_credential.storage_cred.name
  comment         = "External location para a camada raw"
}


resource "databricks_external_location" "ext_location_bronze" {
  name            = "ext_bronze_location_unity"
  url             = "abfss://bronze@datalakecfacilbr.dfs.core.windows.net/unity"
  credential_name = databricks_storage_credential.storage_cred.name
  comment         = "External location para a camada bronze"
  
}

resource "databricks_external_location" "ext_location_silver" {
  name            = "ext_silver_location_unity"
  url             = "abfss://silver@datalakecfacilbr.dfs.core.windows.net/unity"
  credential_name = databricks_storage_credential.storage_cred.name
  comment         = "External location para a camada silver"
}

resource "databricks_external_location" "ext_location_gold" {
  name            = "ext_gold_location_unity"
  url             = "abfss://gold@datalakecfacilbr.dfs.core.windows.net/unity"
  credential_name = databricks_storage_credential.storage_cred.name
  comment         = "External location para a camada gold"
}


resource "databricks_external_location" "ext_location_governance" {
  name            = "ext_governance_location_unity"
  url             = "abfss://governance@datalakecfacilbr.dfs.core.windows.net/unity"
  credential_name = databricks_storage_credential.storage_cred.name
  comment         = "External location para a camada governance"
}

# # # -------------------------------------------------
# # # Associar Workspace ao Metastore
# # # -------------------------------------------------
resource "databricks_metastore_assignment" "assign_uc" {
  workspace_id = azurerm_databricks_workspace.adb.workspace_id
  metastore_id = databricks_metastore.unity.id
}


# -------------------------------------------------
# Catálogo "prd"
# -------------------------------------------------
resource "databricks_catalog" "prd" {
  name        = "prd"
  comment     = "Catálogo de produção CrediFácil"
  metastore_id = databricks_metastore.unity.id

  depends_on = [
    databricks_metastore_assignment.assign_uc
  ]
}

 

resource "databricks_cluster" "personal_cluster" {
  cluster_name            = "Personal_Cluster"
  spark_version           = "17.2.x-scala2.13"  # runtime ML
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 10

  autoscale {
    min_workers = 1
    max_workers = 1
  }

  library {
    pypi {
      package = "azure-identity"
    }
  }

  library {
    pypi {
      package = "azure-mgmt-datafactory"
    }
  }
  data_security_mode = "SINGLE_USER"
}


# # -------------------------------------------------
# # Criação dos schemas
# # -------------------------------------------------


# -------------------------------------------------
# Schemas Bronze
# -------------------------------------------------
resource "databricks_schema" "b_ext_rf_empresas" {
  name         = "b_ext_rf_empresas"
  catalog_name = databricks_catalog.prd.name
  comment      = "[Bronze] Dados brutos da Receita Federal sobre empresas registradas"
  storage_root = "abfss://bronze@datalakecfacilbr.dfs.core.windows.net/unity/b_ext_rf_empresas"
  depends_on = [ 
                  databricks_external_location.ext_location_bronze,
                  databricks_external_location.ext_location_gold,
                  databricks_external_location.ext_location_governance,
                  databricks_external_location.ext_location_raw,
                  databricks_external_location.ext_location_silver
   ]
}

resource "databricks_schema" "b_cfacil_credito" {
  name         = "b_cfacil_credito"
  catalog_name = databricks_catalog.prd.name
  comment      = "[Bronze] Dados brutos de clientes PJ do sistema de crédito da Crédito Fácil"
  storage_root = "abfss://bronze@datalakecfacilbr.dfs.core.windows.net/unity/b_cfacil_credito"
  depends_on = [ 
                  databricks_external_location.ext_location_bronze,
                  databricks_external_location.ext_location_gold,
                  databricks_external_location.ext_location_governance,
                  databricks_external_location.ext_location_raw,
                  databricks_external_location.ext_location_silver
   ]
}

# -------------------------------------------------
# Schemas Silver
# -------------------------------------------------
resource "databricks_schema" "s_rf_empresas" {
  name         = "s_rf_empresas"
  catalog_name = databricks_catalog.prd.name
  comment      = "[Silver] Dados tratados e padronizados da Receita Federal sobre empresas registradas"
  storage_root = "abfss://silver@datalakecfacilbr.dfs.core.windows.net/unity/s_rf_empresas"
  depends_on = [ 
                  databricks_external_location.ext_location_bronze,
                  databricks_external_location.ext_location_gold,
                  databricks_external_location.ext_location_governance,
                  databricks_external_location.ext_location_raw,
                  databricks_external_location.ext_location_silver
   ]
}

resource "databricks_schema" "s_cfacil_credito" {
  name         = "s_cfacil_credito"
  catalog_name = databricks_catalog.prd.name
  comment      = "[Silver] Dados tratados de clientes PJ da Crédito Fácil, com qualidade e consistência garantidas"
  storage_root = "abfss://silver@datalakecfacilbr.dfs.core.windows.net/unity/s_cfacil_credito"
  depends_on = [ 
                  databricks_external_location.ext_location_bronze,
                  databricks_external_location.ext_location_gold,
                  databricks_external_location.ext_location_governance,
                  databricks_external_location.ext_location_raw,
                  databricks_external_location.ext_location_silver
   ]
}

# -------------------------------------------------
# Schema Gold
# -------------------------------------------------
resource "databricks_schema" "g_cfacil_credito" {
  name         = "g_cfacil_credito"
  catalog_name = databricks_catalog.prd.name
  comment      = "[Gold] Camada de consumo consolidada com indicadores e métricas de crédito da Crédito Fácil"
  storage_root = "abfss://gold@datalakecfacilbr.dfs.core.windows.net/unity/g_cfacil_credito"
  depends_on = [ 
                  databricks_external_location.ext_location_bronze,
                  databricks_external_location.ext_location_gold,
                  databricks_external_location.ext_location_governance,
                  databricks_external_location.ext_location_raw,
                  databricks_external_location.ext_location_silver
   ]
}


# -------------------------------------------------
# Schema governance
# -------------------------------------------------
resource "databricks_schema" "governance" {
  name         = "governance"
  catalog_name = databricks_catalog.prd.name
  comment      = "Camada de governança"
  storage_root = "abfss://governance@datalakecfacilbr.dfs.core.windows.net/unity/governance"
  depends_on = [ 
                  databricks_external_location.ext_location_bronze,
                  databricks_external_location.ext_location_gold,
                  databricks_external_location.ext_location_governance,
                  databricks_external_location.ext_location_raw,
                  databricks_external_location.ext_location_silver
   ]
}


# -------------------------------------------------
# Criação dos notebooks  - Bronze dados Externos
# -------------------------------------------------
resource "databricks_notebook" "create_table" {
  source   = "${path.module}/notebooks/bronze/ext_rf_pj/ddl-create-table.py"
  path     = "/Workspace/sistemas/credfacil/bronze/ext_rf_pj/ddl-create-table.py"
  language = "PYTHON"
}

resource "databricks_notebook" "main" {
  source   = "${path.module}/notebooks/bronze/ext_rf_pj/main.py"
  path     = "/Workspace/sistemas/credfacil/bronze/ext_rf_pj/main.py"
  language = "PYTHON"
}

resource "databricks_notebook" "rec_pj" {
  source   = "${path.module}/notebooks/bronze/ext_rf_pj/rec_pj.py"
  path     = "/Workspace/sistemas/credfacil/bronze/ext_rf_pj/rec_pj.py"
  language = "PYTHON"
}

# -------------------------------------------------
# Criação dos notebooks  - Silvers dados Externos
# -------------------------------------------------

resource "databricks_notebook" "create_table_silver" {
  source   = "${path.module}/notebooks/silver/ext_rf_pj/ddl-create-table-silver.py"
  path     = "/Workspace/sistemas/credfacil/silver/ext_rf_pj/ddl-create-table-silver.py"
  language = "PYTHON"
}

resource "databricks_notebook" "estabelecimentos" {
  source   = "${path.module}/notebooks/silver/ext_rf_pj/estabelecimentos.py"
  path     = "/Workspace/sistemas/credfacil/silver/ext_rf_pj/estabelecimentos.py"
  language = "PYTHON"
}

resource "databricks_notebook" "motivo" {
  source   = "${path.module}/notebooks/silver/ext_rf_pj/motivo.py"
  path     = "/Workspace/sistemas/credfacil/silver/ext_rf_pj/motivo.py"
  language = "PYTHON"
}

# -------------------------------------------------
# Criação dos notebooks  - Data Quality
# -------------------------------------------------
resource "databricks_notebook" "dq" {
  source   = "${path.module}/notebooks/governance/data_quality/data_quality.py"
  path     = "/Workspace/sistemas/credfacil/governance/data_quality/data_quality.py"
  language = "PYTHON"
}


resource "databricks_notebook" "rules" {
  source   = "${path.module}/notebooks/governance/data_quality/regras_qualidade.py"
  path     = "/Workspace/sistemas/credfacil/governance/data_quality/regras_qualidade.py"
  language = "PYTHON"
}


# -------------------------------------------------
# Criação dos notebooks  - Silvers dados Internos
# -------------------------------------------------

resource "databricks_notebook" "cli" {
  source   = "${path.module}/notebooks/silver/syscredito/clientes_pj.py"
  path     = "/Workspace/sistemas/credfacil/silver/syscredito/clientes_pj.py"
  language = "PYTHON"
}

resource "databricks_notebook" "create_cli" {
  source   = "${path.module}/notebooks/silver/syscredito/ddl-create-tbl-clientes.py"
  path     = "/Workspace/sistemas/credfacil/silver/syscredito/ddl-create-tbl-clientes.py"
  language = "PYTHON"
}

resource "databricks_notebook" "create_cli_silver" {
  source   = "${path.module}/notebooks/silver/syscredito/ddl-create-tbl-silver-clientes.py"
  path     = "/Workspace/sistemas/credfacil/silver/syscredito/ddl-create-tbl-silver-clientes.py"
  language = "PYTHON"
}