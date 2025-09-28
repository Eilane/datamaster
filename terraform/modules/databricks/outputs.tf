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
  value = databricks_cluster.personal_cluster.id
}