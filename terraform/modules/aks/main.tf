resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksclustercfacilbr"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aksclustercfacilbr"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}


# Provider Kubernetes apontando para o AKS
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# Namespace strimzi
resource "kubernetes_namespace" "strimzi" {
  metadata {
    name = "strimzi"
  }
}

# Namespace debezium
resource "kubernetes_namespace" "debezium" {
  metadata {
    name = "debezium"
  }
}