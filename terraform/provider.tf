terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Keeps your provider locked to the stable major version 5
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
  
backend "s3" {
    bucket       = "jerney-tf-state-lock-bucket"
    key          = "devops/terraform.tfstate"
    region       = "ap-south-2"
    encrypt      = true
    # This instructs Terraform to manage concurrent locks directly inside S3
    use_lockfile = true 
  }
}

provider "aws" {
  region     = var.aws_region

  # Production Best Practice: Automatically tag all resources managed by this module
  default_tags {
    tags = var.project_default_tags
  }
}

# Provider configuration for Kubernetes to talk to EKS

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}