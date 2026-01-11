# FastAPI Cloud Deploy

[![CI](https://github.com/pirsquare/infra-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/pirsquare/infra-lab/actions/workflows/ci.yml)
[![Deploy](https://github.com/pirsquare/infra-lab/actions/workflows/deploy.yml/badge.svg)](https://github.com/pirsquare/infra-lab/actions/workflows/deploy.yml)

Production-ready FastAPI template with cloud-agnostic CI/CD and Infrastructure as Code support for **Azure**, **AWS**, **GCP**, and **Kubernetes**.

## Features

- ✅ **FastAPI** with async support
- ✅ **Multi-cloud** deployment (Azure, AWS, GCP, Kubernetes)
- ✅ **GitHub Actions** CI/CD with automated testing
- ✅ **Terraform** Infrastructure as Code for reproducible deployments
- ✅ **Docker** containerization
- ✅ **Comprehensive docs** (DEPLOY, DEVELOPMENT, CONTRIBUTING)
- ✅ **Makefile** for common tasks

## Quick Start

### 1. Local Development
```bash
# Clone and install
git clone https://github.com/pirsquare/infra-lab.git
cd fastapi-cloud-deploy
make install-deps

# Run locally
uvicorn src.main:app --reload
```

Visit http://localhost:8000

### 2. Run Tests
```bash
make test
```

### 3. Deploy

**GitHub Actions (automated):**
```bash
git push origin main  # Trigger CI
# Then manually deploy via Actions tab
gh workflow run deploy.yml -f target=kubernetes -f image_tag=latest
```

**Terraform (manual):**
```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

See [DEPLOY.md](DEPLOY.md) for detailed deployment guides.

## Deployment Targets

### Azure Web App for Containers
```bash
gh workflow run deploy.yml -f target=azure-webapp -f image_tag=latest
```
Requires: `AZURE_CREDENTIALS`, `AZURE_WEBAPP_NAME`

### AWS ECS (Fargate)
```bash
gh workflow run deploy.yml -f target=aws-ecs -f image_tag=latest
```
Requires: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ECR_REPOSITORY`, etc.

### GCP Cloud Run
```bash
gh workflow run deploy.yml -f target=gcp-cloud-run -f image_tag=latest
```
Requires: `GCP_SA_KEY`, `GCP_PROJECT_ID`, `CLOUD_RUN_SERVICE`, etc.

### Kubernetes
```bash
gh workflow run deploy.yml -f target=kubernetes -f image_tag=latest
```
Requires: `KUBE_CONFIG`

## Documentation

| Document | Purpose |
|----------|---------|
| [DEPLOY.md](DEPLOY.md) | Step-by-step deployment guides for all targets |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Local development setup and debugging |
| [terraform/README.md](terraform/README.md) | Terraform-specific documentation |

## CI/CD Pipeline

### Continuous Integration (`.github/workflows/ci.yml`)
- **Tests**: Python 3.10, 3.11, 3.12

Runs on: Push to any branch, Pull requests

### Continuous Deployment (`.github/workflows/deploy.yml`)
- **Triggers**: Manual dispatch with target selection
- **Steps**: Build → Push → Deploy → Verify
- **Supports**: Azure, AWS, GCP, Kubernetes

## Secrets Setup

### GitHub Secrets
Create these in GitHub (Settings → Secrets and variables → Actions):

**Azure:**
```
AZURE_CREDENTIALS    # Service Principal JSON
AZURE_WEBAPP_NAME    # Web App name
```

**AWS:**
```
AWS_ACCESS_KEY_ID       # IAM user key
AWS_SECRET_ACCESS_KEY   # IAM user secret
AWS_REGION              # e.g., us-east-1
AWS_ECR_REPOSITORY      # ECR repo name
AWS_ECS_CLUSTER         # ECS cluster name
AWS_ECS_SERVICE         # ECS service name
```

**GCP:**
```
GCP_SA_KEY              # Service Account JSON
GCP_PROJECT_ID          # GCP project ID
GCP_REGION              # e.g., us-central1
GCP_AR_REPOSITORY       # Artifact Registry repo
CLOUD_RUN_SERVICE       # Cloud Run service name
```

**Kubernetes:**
```
KUBE_CONFIG             # kubeconfig YAML content
```

See [DEPLOY.md](DEPLOY.md) for detailed setup instructions.

## Makefile Commands

```bash
make help                # List all available commands
make install-deps        # Install Python and Terraform deps
make test                # Run tests
make init target=<env>   # Initialize Terraform
make plan target=<env>   # Plan Terraform deployment
make apply target=<env>  # Apply Terraform deployment
make destroy target=<env> # Destroy infrastructure
make clean               # Clean build artifacts
```

## Testing

```bash
# Run all tests
make test

# Run specific test file
pytest tests/test_app.py
```

## Customization

### Update App Name
Replace `fastapi-app` across:
- Terraform variables (terraform.tfvars)
- Kubernetes manifests (k8s/)
- GitHub workflows (.github/workflows/)

### Change Container Port
Update `container_port` in:
- Dockerfile (`EXPOSE`)
- Kubernetes manifest
- Terraform variables

### Add Environment Variables
Edit `src/main.py` and reference via:
- Docker environment
- Kubernetes ConfigMap/Secret
- Terraform provider-specific methods

## License
Licensed under MIT. See [LICENSE](LICENSE) for details.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
