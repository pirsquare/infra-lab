# Deployment Guide

This guide walks you through deploying the FastAPI app to various cloud platforms.

## Table of Contents
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Deployment Options](#deployment-options)
- [GitHub Actions CD](#github-actions-cd)
- [Terraform Infrastructure](#terraform-infrastructure)
- [Post-Deployment](#post-deployment)

## Quick Start

### Option 1: GitHub Actions (Automated)
```bash
git push origin main
# Then trigger from Actions tab or use:
gh workflow run deploy.yml -f target=kubernetes -f image_tag=latest
```

### Option 2: Terraform (Manual)
```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Prerequisites

### For GitHub Actions:
- GitHub repository with Actions enabled
- Required secrets set (see [README.md](README.md))

### For Terraform:
- Terraform >= 1.0 installed
- Cloud provider credentials configured
- Docker image pushed to a registry (GHCR, ECR, or Artifact Registry)

## Deployment Options

### 1. Azure Web App for Containers

**Via GitHub Actions:**
```bash
gh workflow run deploy.yml -f target=azure-webapp -f image_tag=latest
```

**Via Terraform:**
```bash
cd terraform/azure
terraform init
terraform plan -var-file=../environments/azure.tfvars
terraform apply -var-file=../environments/azure.tfvars
```

**Manual Azure CLI:**
```bash
az login
az containerapp create \
  --name fastapi-app \
  --resource-group myresourcegroup \
  --image ghcr.io/myorg/myrepo:latest \
  --env-vars PORT=8000
```

### 2. AWS ECS (Fargate)

**Via GitHub Actions:**
```bash
gh workflow run deploy.yml -f target=aws-ecs -f image_tag=latest
```

**Via Terraform:**
```bash
cd terraform/aws
terraform init
terraform plan
terraform apply
```

**Manual AWS CLI:**
```bash
aws ecr create-repository --repository-name fastapi-app --region us-east-1
docker tag fastapi-app:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/fastapi-app:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/fastapi-app:latest
```

### 3. GCP Cloud Run

**Via GitHub Actions:**
```bash
gh workflow run deploy.yml -f target=gcp-cloud-run -f image_tag=latest
```

**Via Terraform:**
```bash
cd terraform/gcp
terraform init
terraform plan
terraform apply
```

**Manual gcloud CLI:**
```bash
gcloud services enable run.googleapis.com artifactregistry.googleapis.com
gcloud run deploy fastapi-app \
  --image ghcr.io/myorg/myrepo:latest \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated
```

### 4. Kubernetes

**Via GitHub Actions:**
```bash
gh workflow run deploy.yml -f target=kubernetes -f image_tag=latest
```

**Via Terraform:**
```bash
cd terraform/kubernetes
terraform init
terraform plan
terraform apply
```

**Manual kubectl:**
```bash
kubectl apply -f k8s/
kubectl set image deployment/fastapi-app app=ghcr.io/myorg/myrepo:latest
kubectl rollout status deployment/fastapi-app
```

## GitHub Actions CD

The automated CD workflow (`.github/workflows/deploy.yml`) includes:
- Docker image build and push
- Cloud-specific authentication
- Deployment to the selected target
- Rollout verification

**Trigger manually:**
```bash
gh workflow run deploy.yml -f target=<target> -f image_tag=<tag>
```

**Required secrets** (see [README.md](README.md) for setup):
- `AZURE_CREDENTIALS`, `AZURE_WEBAPP_NAME` (Azure)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc. (AWS)
- `GCP_SA_KEY`, `GCP_PROJECT_ID`, etc. (GCP)
- `KUBE_CONFIG` (Kubernetes)

## Terraform Infrastructure

Terraform enables infrastructure as code for reproducible deployments.

### Setup Terraform

1. **Initialize backend** (optional for remote state):
```bash
cd terraform
terraform init -upgrade
```

2. **Create `terraform.tfvars`**:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

3. **Review and apply**:
```bash
terraform plan
terraform apply
```

### Environment-Specific Deployments

Create separate tfvars files for each environment:
```bash
# Production
terraform apply -var-file=terraform.prod.tfvars

# Staging
terraform apply -var-file=terraform.staging.tfvars
```

## Post-Deployment

### Verify Deployment

**Azure:**
```bash
az containerapp show --name fastapi-app --resource-group myresourcegroup
```

**AWS:**
```bash
aws ecs describe-services --cluster fastapi-cluster --services fastapi-service
```

**GCP:**
```bash
gcloud run services describe fastapi-app --region us-central1
```

**Kubernetes:**
```bash
kubectl get deployment fastapi-app
kubectl logs deployment/fastapi-app -f
```

### Health Checks

Visit the app's health endpoint:
```bash
curl https://<your-deployed-url>/
```

### Monitor Logs

**Kubernetes:**
```bash
kubectl logs -f deployment/fastapi-app
```

**AWS:**
```bash
aws logs tail /ecs/fastapi-app --follow
```

**GCP:**
```bash
gcloud run services describe fastapi-app --format="value(status.url)"
# Then check logs in Cloud Logging console
```

### Rollback

**Kubernetes:**
```bash
kubectl rollout undo deployment/fastapi-app
```

**AWS ECS:**
Update the task definition revision and update the service.

**GCP Cloud Run:**
Deploy a previous image tag or revision.

## Cleanup

### Destroy Infrastructure (Terraform)
```bash
terraform destroy
```

### Delete Cloud Resources (Manual)
```bash
# Azure
az containerapp delete --name fastapi-app --resource-group myresourcegroup

# AWS
aws ecs delete-service --cluster fastapi-cluster --service fastapi-service --force

# GCP
gcloud run services delete fastapi-app --region us-central1

# Kubernetes
kubectl delete -f k8s/
```

## Troubleshooting

See [DEVELOPMENT.md](DEVELOPMENT.md) for debugging guidance.
