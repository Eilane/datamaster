output "azurerm_service" {
  value = azurerm_databricks_workspace.adb.id
}


output "workspace_url" {
  value = azurerm_databricks_workspace.adb.workspace_url
}

output "workspace_id" {
  value = azurerm_databricks_workspace.adb.id
}

output "cluster_id" {
  value = databricks_cluster.datamaster.id
}

output "ext_location_raw_id" {
  value = databricks_external_location.ext_location_raw.id
}

output "databricks_token" {
  value     = databricks_token.token.token_value
  sensitive = true
}
