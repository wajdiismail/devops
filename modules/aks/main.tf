terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Generate random suffix for unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  
  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.cluster_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  
  tags = var.tags
}

# AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.cluster_name}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.cluster_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = var.tags
}

# AKS Cluster with 2 node pools
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.cluster_name
  
  # Default node pool (System Pool)
  default_node_pool {
    name                = "systempool"
    vm_size             = "Standard_D2s_v3"
    node_count          = var.node_count
    vnet_subnet_id      = azurerm_subnet.aks.id
    os_disk_size_gb     = 128
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    
    # Tags for the node pool
    tags = merge(var.tags, {
      NodePool = "system"
    })
  }
  
  # Identity (Managed Identity)
  identity {
    type = "SystemAssigned"
  }
  
  # Network configuration
  network_profile {
    network_plugin   = "azure"
    network_policy   = "azure"
    service_cidr     = "10.2.0.0/16"
    dns_service_ip   = "10.2.0.10"
  }
  
  # RBAC configuration
  role_based_access_control_enabled = true
  
  # Add-ons
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
  
  # Azure Policy add-on
  azure_policy_enabled = true
  
  tags = var.tags
  
  depends_on = [azurerm_subnet.aks]
}

# User Node Pool (Second worker pool)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D2s_v3"
  node_count            = var.node_count
  vnet_subnet_id        = azurerm_subnet.aks.id
  os_disk_size_gb       = 128
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 5
  
  # Add taint for user workloads
  node_taints = ["workload=user:NoSchedule"]
  
  tags = merge(var.tags, {
    NodePool = "user"
  })
  
  depends_on = [azurerm_kubernetes_cluster.main]
}