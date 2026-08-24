#resource group

resource "azurerm_resource_group" "rg01" {
  name     = "resource_group_01"
  location = "central India"
}

#public ip
resource "azurerm_public_ip" "publicip01" {
  name                = "PublicIP"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  allocation_method   = "Static"
}

#Load balancer (load balancer needs the frontend ip to listen and the frontend ip is associated with either public or private IP)
resource "azurerm_lb" "loadbalancer01" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name

  frontend_ip_configuration {
    name                 = "frontendpublicip01"
    public_ip_address_id = azurerm_public_ip.publicip01.id
  }
}

#vnet
resource "azurerm_virtual_network" "vnet01" {
  name                = "virtual_network01"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name

  address_space = ["10.0.0.0/16"]
}
#Subnet

 resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg01.name
  virtual_network_name = azurerm_virtual_network.vnet01.name
  address_prefixes     = ["10.0.1.0/24"]
}

#NIC card
resource "azurerm_network_interface" "nic" {
  count = 2

  name                = "nic-${count.index + 1}"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

#virtual machine
resource "azurerm_windows_virtual_machine" "vms" {
    count = 2
  name                = "vms-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg01.name
  location            = azurerm_resource_group.rg01.location
  size                = "Standard_D2_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

}

#backend pool

resource "azurerm_lb_backend_address_pool" "backendpool01" {
  loadbalancer_id = azurerm_lb.loadbalancer01.id
  name            = "BackEndAddressPool"
}

# configuring backend pool with the nic

resource "azurerm_network_interface_backend_address_pool_association" "nic_backendpool" {
  count = 2

  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpool01.id
}

# healthprobe

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.loadbalancer01.id
  name            = "health-probe"
  port            = 80
  protocol        = "Tcp"
}