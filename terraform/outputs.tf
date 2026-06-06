##VPC - outputs ###

output "vpc_id" {
  description = "The unique identifier of the main production VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The core network CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs for the massive /20 private subnets hosting EKS nodes and pods"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs for the /24 public subnets hosting load balancers and NAT gateways"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "The static public Elastic IP addresses of your NAT Gateways (useful for whitelisting)"
  value       = module.vpc.nat_public_ips
}

##EKS -outputs ###

output "cluster_name" {
  description = "The assigned name of the standard EKS cluster control plane"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The secure HTTPS endpoint URL used by kubectl to communicate with the EKS API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The master security group ID attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "The shared security group ID attached to all EC2 worker nodes"
  value       = module.eks.node_security_group_id
}

# Output the ArgoCD Initial Admin Password
data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

output "argocd_initial_admin_password" {
  description = "The initial admin password for ArgoCD"
  value       = nonsensitive(data.kubernetes_secret.argocd_admin_password.data["password"])
  sensitive   = true # Terraform will mask this in output unless -raw is used
}

# Use conditional logic to prevent "index null" errors
output "argocd_alb_hostname" {
  description = "The public DNS name for the ArgoCD Load Balancer"
  value = try(
    data.kubernetes_ingress_v1.argocd_ingress.status[0].load_balancer[0].ingress[0].hostname,
    "ALB still provisioning..."
  )
}

output "app_access_url" {
  description = "The public URL to access the Jerney Blog App"
  value = try(
    "http://${data.kubernetes_ingress_v1.jerney_app_ingress.status[0].load_balancer[0].ingress[0].hostname}",
    "App ALB still provisioning..."
  )
}