resource "azurerm_resource_group" "portfilo" {
  name     = "portfilo-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "portfilo" {
  name                = "portfilo-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.portfilo.location
  resource_group_name = azurerm_resource_group.portfilo.name
}

resource "azurerm_subnet" "portfilo" {
  name                 = "portfilo-subnet"
  resource_group_name  = azurerm_resource_group.portfilo.name
  virtual_network_name = azurerm_virtual_network.portfilo.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "jenkins_public_ip" {
  name                = "jenkins-public-ip"
  location            = azurerm_resource_group.portfilo.location
  resource_group_name = azurerm_resource_group.portfilo.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jenkins_nic" {
  name                = "jenkins-nic"
  location            = azurerm_resource_group.portfilo.location
  resource_group_name = azurerm_resource_group.portfilo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.portfilo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                = "jenkins-vm"
  location            = azurerm_resource_group.portfilo.location
  resource_group_name = azurerm_resource_group.portfilo.name
  network_interface_ids = [azurerm_network_interface.jenkins_nic.id]
  size                = "Standard_B2s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "jenkinsvm"
  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false
}