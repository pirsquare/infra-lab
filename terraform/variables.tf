terraform {
  required_version = ">= 1.0"
}

variable "app_name" {
  description = "Application name (used across all resources)"
  type        = string
  default     = "fastapi-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "docker_image" {
  description = "Docker image URI (e.g., ghcr.io/owner/repo:tag)"
  type        = string
}

variable "container_port" {
  description = "Container listening port"
  type        = number
  default     = 8000
}

variable "replicas" {
  description = "Number of replicas/instances"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    project     = "fastapi-cloud"
    managed_by  = "terraform"
    created_at  = "2026-01-12"
  }
}
