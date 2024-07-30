#Declare existing Resource Group
data "azurerm_resource_group" "sandbox-rg" {
  name = "mbleezarde-sandbox"
}

#Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.network
  address_space       = ["10.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.sandbox-rg.name
  location            = var.location
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = data.azurerm_resource_group.sandbox-rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "ip" {
  count               = length(var.vm_names)
  name                = "${var.vm_names[count.index]}-pubIP"
  resource_group_name = data.azurerm_resource_group.sandbox-rg.name
  location            = var.location
  allocation_method   = "Dynamic"
}

# Create nics using loop
resource "azurerm_network_interface" "nic" {
  count               = length(var.vm_names)
  name                = "${var.vm_names[count.index]}-nic"
  resource_group_name = data.azurerm_resource_group.sandbox-rg.name
  location            = var.location

  ip_configuration {
    name                          = "${var.vm_names[count.index]}-ip_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip[count.index].id
  }
}

#Create VMs using loop
resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                 = length(var.vm_names)
  name                  = var.vm_names[count.index]
  resource_group_name   = data.azurerm_resource_group.sandbox-rg.name
  location              = var.location
  admin_username        = "adminuser"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.vm_names[count.index]}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

}