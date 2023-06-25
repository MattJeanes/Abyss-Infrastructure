terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      version = "3.62.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.8.0"
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

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}
