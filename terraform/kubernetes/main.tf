# Terraform for Kubernetes
# Assumes a cluster already exists and kubeconfig is configured.
# Use kubectl provider to manage K8s resources (optional).

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "kubernetes" {
  # Kubeconfig is read from environment or ~/.kube/config by default.
  # To use a specific config file, set: config_path = var.kubeconfig_path
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "infra-lab"
}

variable "docker_image" {
  description = "Docker image (e.g., ghcr.io/owner/repo:latest)"
  type        = string
}

variable "replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8000
}

# Kubernetes Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = "app"
          image = var.docker_image

          port {
            container_port = var.container_port
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

# Kubernetes Service
resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = var.app_name
    }

    port {
      name        = "http"
      port        = 80
      target_port = var.container_port
    }
  }
}

output "deployment_name" {
  value       = kubernetes_deployment.app.metadata[0].name
  description = "Kubernetes deployment name"
}

output "service_name" {
  value       = kubernetes_service.app.metadata[0].name
  description = "Kubernetes service name"
}
