terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-lb-demo"
  location = "East US"
}

# -----------------------------
# Virtual Network & Subnet
# -----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-lb-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-lb-demo"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# -----------------------------
# Public IP (Standard)
# -----------------------------
resource "azurerm_public_ip" "pip" {
  name                = "pip-lb-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -----------------------------
# Load Balancer
# -----------------------------
resource "azurerm_lb" "lb" {
  name                = "lb-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-public"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# -----------------------------
# Backend Pool
# -----------------------------
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

# -----------------------------
# Health Probe (HTTP)
# -----------------------------
resource "azurerm_lb_probe" "http_probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# -----------------------------
# Load Balancing Rule (HTTP)
# -----------------------------
resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}

# -----------------------------
# Associate existing VM NICs with backend pool
# -----------------------------
resource "azurerm_network_interface_backend_address_pool_association" "vm11_assoc" {
  network_interface_id    = "/subscriptions/3f51e757-9bd9-42e5-a6b6-e290cdd71dac/resourceGroups/rg-lb-demo/providers/Microsoft.Network/networkInterfaces/vm11996_z2"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm12_assoc" {
  network_interface_id    = "/subscriptions/3f51e757-9bd9-42e5-a6b6-e290cdd71dac/resourceGroups/rg-lb-demo/providers/Microsoft.Network/networkInterfaces/vm12910_z2"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}
