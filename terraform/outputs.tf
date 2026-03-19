output "eks_cluster_endpoint" {
  description = "EKS Cluster Control Plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}
