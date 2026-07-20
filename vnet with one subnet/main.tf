#resource group

resource "azurerm_resource_group" "rg1" {
  name     = "resourcegroup1"
  location = "West Europe"
}

#Vnet

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnetone"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "subnetone"
    address_prefixes = ["10.0.1.0/24"]
  }
}