variable "aws_region" {
  type        = string
  description = "The target AWS Region where infrastructure resources will be provisioned."
  default     = "ap-south-2"
}
variable "environment" {
  type        = string
  description = "The environment for which infrastructure resources are being provisioned."
  default     = "DevOps"
}
variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster to be created."
  default     = "jerney-eks-cluster"
}
variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for the EKS cluster."
  default     = "1.31"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "172.16.0.0/16"
}

variable "project_default_tags" {
  type        = map(string)
  description = "A global map of metadata tags applied automatically to all supported resources."
  default = {
    Environment = "DevOps"
    ManagedBy   = "Terraform"
    Project     = "Jerney-Blog-App"
  }
}