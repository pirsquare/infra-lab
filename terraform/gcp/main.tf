terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "Application name (used for Cloud Run service)"
  type        = string
}

variable "artifact_registry_url" {
  description = "Artifact Registry image URL (e.g., us-central1-docker.pkg.dev/project/apps/image)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8000
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

# Cloud Run Service
resource "google_cloud_run_service" "app" {
  name     = var.app_name
  location = var.gcp_region

  template {
    spec {
      containers {
        image = "${var.artifact_registry_url}:${var.image_tag}"
        ports {
          container_port = var.container_port
        }
        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }
      service_account_email = google_service_account.cloud_run.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Service Account for Cloud Run
resource "google_service_account" "cloud_run" {
  account_id   = "${var.app_name}-sa"
  display_name = "Service Account for ${var.app_name}"
}

# Cloud Run IAM: Allow public access
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.app.name
  location = google_cloud_run_service.app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "cloud_run_url" {
  value       = google_cloud_run_service.app.status[0].url
  description = "Cloud Run service URL"
}

output "service_account_email" {
  value       = google_service_account.cloud_run.email
  description = "Service account email"
}
