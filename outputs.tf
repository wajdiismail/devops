output "kube_config" {
  description = "Kubeconfig for cluster access"
  value       = module.aks.kube_config
  sensitive   = true
}

output "cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks.cluster_id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.aks.resource_group_name
}

output "system_pool_name" {
  description = "System node pool name"
  value       = module.aks.system_pool_nodes
}

output "user_pool_name" {
  description = "User node pool name"
  value       = module.aks.user_pool_nodes
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.aks.log_analytics_workspace_id
}