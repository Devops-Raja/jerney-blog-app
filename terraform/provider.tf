terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Keeps your provider locked to the stable major version 5
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