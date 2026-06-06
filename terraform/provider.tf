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
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
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
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}