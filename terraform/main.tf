###----EKS-cluster-AUTOMODE----###

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs= (slice(data.aws_availability_zones.available.names, 0, 2))
}

###---- VPC ----###
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.cidr
  azs = local.azs
    private_subnets = [
    "172.16.0.0/20",  # Zone A private pool (IPs: 172.16.0.0   to 172.16.15.255)
    "172.16.16.0/20"  # Zone B private pool (IPs: 172.16.16.0  to 172.16.31.255)
    ]

    public_subnets = [
    "172.16.48.0/24", # Zone A public pool  (IPs: 172.16.48.0  to 172.16.48.255)
    "172.16.49.0/24"  # Zone B public pool  (IPs: 172.16.49.0  to 172.16.49.255)
  ]


  enable_nat_gateway = true
  single_nat_gateway = true  ##cost saving for demo

 # Tags required for EKS Auto Mode to discover subnets

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

}

# ---- EKS Cluster (AUTO MODE) ----
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version # Use standard, stable Kubernetes versions

  # Network Integration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # EKS will run pods in your massive /20 private pools
  enable_irsa = true # Enable IAM Roles for Service Accounts for secure pod permissions
  # Endpoint Security Setup
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"] # Automatically scales instances based on your workloads
  }
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  
  # Allow current caller (your IAM user/role) to manage the cluster
  enable_cluster_creator_admin_permissions = true
}



