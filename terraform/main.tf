terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      version = "=3.4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.13.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.abyss.kube_config.0.host
  username               = azurerm_kubernetes_cluster.abyss.kube_config.0.username
  password               = azurerm_kubernetes_cluster.abyss.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.abyss.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.abyss.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.abyss.kube_config.0.cluster_ca_certificate)
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
