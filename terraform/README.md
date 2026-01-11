# Terraform Infrastructure Guide

This directory contains Infrastructure as Code (IaC) templates for deploying the FastAPI app to various cloud platforms.

## Structure

- **azure/**: Terraform for Azure Web App for Containers
- **aws/**: Terraform for AWS ECS (Fargate)
- **gcp/**: Terraform for GCP Cloud Run
- **kubernetes/**: Terraform for Kubernetes (using Terraform Kubernetes provider)
- **environments/**: Example tfvars files per target

## Prerequisites

Install [Terraform](https://www.terraform.io/downloads.html) (>= 1.0).

### For each provider:
- **Azure**: `az login` and set `AZURE_SUBSCRIPTION_ID`
- **AWS**: Configure AWS credentials (`~/.aws/credentials` or `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`)
- **GCP**: `gcloud auth application-default login` and set `GOOGLE_PROJECT_ID`
- **Kubernetes**: `kubectl` configured with a valid kubeconfig

## Usage

### Initialize Terraform
```bash
cd terraform/azure  # or aws, gcp, kubernetes
terraform init
```

### Plan
```bash
terraform plan -var-file=../environments/azure.tfvars
# or use environment-specific file
```

### Apply
```bash
terraform apply -var-file=../environments/azure.tfvars
```

### Example: Deploy to Azure
```bash
cd terraform/azure
terraform init
terraform plan -var-file=../environments/azure.tfvars
terraform apply -var-file=../environments/azure.tfvars
```

### Destroy Resources
```bash
terraform destroy -var-file=../environments/azure.tfvars
```

## Customization

Update the variables in each main.tf or create a custom `.tfvars` file:

```hcl
# custom.tfvars
resource_group_name = "my-rg"
app_name            = "my-app"
docker_image_url    = "ghcr.io/myorg/myrepo:latest"
```

Then apply:
```bash
terraform apply -var-file=custom.tfvars
```

## State Management

By default, Terraform stores state locally in `.terraform/`. For production, consider using remote state:

- **Azure**: Use `azurerm_storage_account` + `azurerm_storage_container`
- **AWS**: Use S3 bucket for state
- **GCP**: Use GCS bucket for state

Example backend config for Azure:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstate"
    container_name       = "state"
    key                  = "azure.tfstate"
  }
}
```

## Notes

- All `.tfvars` files are ignored by `.gitignore` to protect credentials.
- Use environment variables or Terraform Cloud for sensitive inputs.
- Update image URLs and resource names before applying.
- Test in non-production environments first.
