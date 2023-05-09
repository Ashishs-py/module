
# Create a resource group
resource "azurerm_resource_group" "ash_rg1" {
  name     = var.rg_ash
  location = var.location
}
resource "azurerm_virtual_network" "vnet11" {
  depends_on = [azurerm_resource_group.ash_rg1]
  name                = var.vnet11
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_ash
}

resource "azurerm_subnet" "shuub1" {
  
  name                 = "shuub1"
  resource_group_name  = var.rg_ash
  virtual_network_name = var.vnet11
  address_prefixes     = ["10.0.2.0/24"]
} 

resource "azurerm_network_interface" "niiic" {
  name                = "niiic"
  location            = var.location
  resource_group_name = azurerm_resource_group.ash_rg1.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.shuub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.aship.id
  }
}


resource "azurerm_linux_virtual_machine" "Kali1" {
  name                = "Kali1"
  resource_group_name = var.rg_ash
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      ="Kali@1234567"
  disable_password_authentication= false
  network_interface_ids = [
    azurerm_network_interface.niiic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "aship" {
  name                = "aship"
  location            = var.location
  resource_group_name = azurerm_resource_group.ash_rg1.name
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}


output "public_ip_address" {
  value = azurerm_public_ip.aship.ip_address
}

  
