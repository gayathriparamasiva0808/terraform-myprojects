#required_providers

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

#subscription id

provider "azurerm" {
  features {}
  subscription_id = "2806b7e1-7cbe-45b6-9b85-7856288f8f85"
}

