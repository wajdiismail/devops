resource_group_name = "aks-terraform-demo-rg"
location            = "Canada Central"
cluster_name        = "aks-demo-cluster"
node_count          = 2
tags = {
  Environment = "Development"
  Project     = "AKS-Terraform-Demo"
  ManagedBy   = "Terraform"
  CreatedDate = "2026-03-27"
  demo        = "true"
}