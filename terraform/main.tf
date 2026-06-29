# -----------------------------------------------------------------
# Harrington Capital plc -- Azure Infrastructure
# Phase 1: Resource Groups, VNet, Subnets, NSGs, VMs
# -----------------------------------------------------------------
# CANDIDATE TASK: Complete all TODO sections.
# BUILD -> VERIFY -> SUBMIT
# -----------------------------------------------------------------

# -- RESOURCE GROUPS ----------------------------------------------

resource "azurerm_resource_group" "prod" {
  name     = "rg-${var.project}-prod"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "dev" {
  name     = "rg-${var.project}-dev"
  location = var.location
  tags     = merge(var.tags, { Environment = "dev" })
}

# -- VIRTUAL NETWORK ----------------------------------------------

resource "azurerm_virtual_network" "prod" {
  name                = "vnet-${var.project}-prod"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  address_space       = [var.address_space]
  tags                = var.tags
}

# -- SUBNETS ------------------------------------------------------

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = [var.subnet_app]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = [var.subnet_data]
}

resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt"
  resource_group_name  = azurerm_resource_group.prod.name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = [var.subnet_mgmt]
}

# -- NETWORK SECURITY GROUPS --------------------------------------

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  tags                = var.tags

  security_rule {
    name                       = "deny-ssh-internet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "mgmt" {
  name                = "nsg-mgmt"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  tags                = var.tags

  # TODO (Phase 1 Task):
  # Add a security_rule block that allows RDP (port 3389) inbound
  # from the management subnet only (source: 10.0.3.0/24).
  # Priority: 100 | Name: allow-rdp-mgmt-inbound
  # VERIFY: terraform plan shows this rule
  # SUBMIT: paste the terraform plan output in your submission

  security_rule {
    name                       = "allow-ssh-mgmt-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnet_mgmt
    destination_address_prefix = "*"
  }
}

# -- NSG ASSOCIATIONS ---------------------------------------------

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

# -- PUBLIC IPs ---------------------------------------------------

resource "azurerm_public_ip" "dc01" {
  name                = "pip-${var.project}-dc01"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "app01" {
  name                = "pip-${var.project}-app01"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "mon01" {
  name                = "pip-${var.project}-mon01"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# -- NETWORK INTERFACES -------------------------------------------

resource "azurerm_network_interface" "dc01" {
  name                = "nic-${var.project}-dc01"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.10"
    public_ip_address_id          = azurerm_public_ip.dc01.id
  }
}

resource "azurerm_network_interface" "app01" {
  name                = "nic-${var.project}-app01"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
    public_ip_address_id          = azurerm_public_ip.app01.id
  }
}

resource "azurerm_network_interface" "mon01" {
  name                = "nic-${var.project}-mon01"
  resource_group_name = azurerm_resource_group.prod.name
  location            = azurerm_resource_group.prod.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.20"
    public_ip_address_id          = azurerm_public_ip.mon01.id
  }
}

# -- WINDOWS SERVER VM (Domain Controller) ------------------------

resource "azurerm_windows_virtual_machine" "dc01" {
  name                  = "vm-${var.project}-prod-dc01"
  resource_group_name   = azurerm_resource_group.prod.name
  location              = azurerm_resource_group.prod.location
  size                  = var.vm_size_windows
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.dc01.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

# -- LINUX VMs ----------------------------------------------------

resource "azurerm_linux_virtual_machine" "app01" {
  name                  = "vm-${var.project}-prod-app01"
  resource_group_name   = azurerm_resource_group.prod.name
  location              = azurerm_resource_group.prod.location
  size                  = var.vm_size_linux
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.app01.id]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "mon01" {
  name                  = "vm-${var.project}-prod-mon01"
  resource_group_name   = azurerm_resource_group.prod.name
  location              = azurerm_resource_group.prod.location
  size                  = var.vm_size_linux
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.mon01.id]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
