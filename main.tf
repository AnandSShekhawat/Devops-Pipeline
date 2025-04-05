###### Provider Configuration ######
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = "ec89cff3-47cc-42aa-bfbc-bcfeaee71336"
}


###### Backend Configuration ######
terraform {
  backend "azurerm" {
    resource_group_name  = "anand.shekhawat02"
    storage_account_name = "tfstate12889"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}


###### Resource Group ######
data "azurerm_resource_group" "existing" {
  name = "anand.shekhawat02"
}


###### Network Security Group ######
resource "azurerm_network_security_group" "nsg" {
  name                = "Static-website-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 290
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Jenkins"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 8080
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

###### Public IP Address ######
resource "azurerm_public_ip" "Static-website-pip" {
  name                = "Static-website-pip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

###### Virtual Network ######
resource "azurerm_virtual_network" "Static-Website-Vnet" {
  name                = "Static-Website-Vnet"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  address_space       = ["10.0.0.0/16"]
}

###### Subnet ######
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.Static-Website-Vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_network_security_group.nsg]
}

resource "azurerm_subnet_network_security_group_association" "subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


###### Network Interface ######
resource "azurerm_network_interface" "Static-website-nic" {
  name                = "Static-website-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Static-website-pip.id
  }
}

###### Virtual Machine ######
resource "azurerm_linux_virtual_machine" "Static-website-vm" {
  name                            = "Static-website-vm"
  location                        = data.azurerm_resource_group.existing.location
  resource_group_name             = data.azurerm_resource_group.existing.name
  size                            = "Standard_B2ms"
  admin_username                  = "azureadmin"
  admin_password                  = "Password12346"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.Static-website-nic.id,
  ]

  computer_name = "azureadmin"

  os_disk {
    name                 = "my-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}

output "public_ip" {
  value = azurerm_public_ip.Static-website-pip.ip_address
}