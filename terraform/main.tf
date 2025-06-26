terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
provider "azurerm" {
  features {}
}

  resource "azurerm_resource_group" "rg" {
    name     = var.resource_group
    location = var.location
  }

  resource "azurerm_virtual_network" "vnet" {
    name                = "vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
  }

  resource "azurerm_subnet" "subnet" {
    name                 = "subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
  }

  resource "azurerm_public_ip" "pip" {
    name                = "public-ip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Dynamic"
  }

  resource "azurerm_network_interface" "nic" {
    name                = "nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
      name                          = "ipconfig"
      subnet_id                     = azurerm_subnet.subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.pip.id
    }
  }

  resource "azurerm_linux_virtual_machine" "vm" {
    name                  = "web-vm"
    resource_group_name   = azurerm_resource_group.rg.name
    location              = azurerm_resource_group.rg.location
    size                  = "Standard_B1s"
    admin_username        = var.admin_username
    network_interface_ids = [azurerm_network_interface.nic.id]

    admin_ssh_key {
      username   = var.admin_username
      public_key = file(var.ssh_public_key)
    }

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
  }

  output "public_ip" {
    value = azurerm_public_ip.pip.ip_address
  }
