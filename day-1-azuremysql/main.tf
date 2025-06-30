provider "azurerm" {
  features {}
  subscription_id = "your-sub-id"
}

# Use existing or create a new Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "mysql-rg"
  location = "Southeast Asia"
}

# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "myflexiblesqlserver01"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "mysqladmin"
  administrator_password = "MyS3cureP@ssword123"  # Use a secure password
  sku_name               = "B_Standard_B1ms"                # Basic tier
  version                = "8.0.21"
             
  backup_retention_days  = 7
  zone                   = "1"                   # Optional; availability zone
}

# Subnet Delegation (if needed)
resource "azurerm_virtual_network" "vnet" {
  name                = "mysql-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]

  delegation {
    name = "mysql-delegation"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

