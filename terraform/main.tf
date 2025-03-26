terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.2.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azurerm" {
  alias           = "old"
  subscription_id = var.azure_subscription_id_old
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

data "azurerm_subscription" "old" {
  subscription_id = var.azure_subscription_id_old
}
