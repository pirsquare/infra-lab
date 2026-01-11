# Terraform Root Configuration
# This file serves as the main entry point for deploying infrastructure.
# Use terraform.tfvars to override defaults per environment.

terraform {
  required_version = ">= 1.0"
  # Uncomment below for remote state management
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state"
  #   storage_account_name = "tfstate"
  #   container_name       = "state"
  #   key                  = "main.tfstate"
  # }
}

variable "target" {
  description = "Deployment target (azure, aws, gcp, kubernetes)"
  type        = string
  default     = "kubernetes"
  validation {
    condition     = contains(["azure", "aws", "gcp", "kubernetes"], var.target)
    error_message = "target must be one of: azure, aws, gcp, kubernetes"
  }
}

# Include target-specific module
module "deployment" {
  source = "./${var.target}"

  app_name       = var.app_name
  environment    = var.environment
  docker_image   = var.docker_image
  container_port = var.container_port
  replicas       = var.replicas
  tags           = var.tags
}

output "deployment_info" {
  description = "Deployment-specific outputs"
  value       = module.deployment
  sensitive   = true
}
