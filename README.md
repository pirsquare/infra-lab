# Python CI/CD with GitHub Actions (FastAPI + Cloud-Agnostic Deploy)

[![CI](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml)
[![Deploy](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/deploy.yml/badge.svg)](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/deploy.yml)

This repo demonstrates a minimal Python stack (FastAPI) with CI (lint + tests) and cloud-agnostic CD: build a container image, push to a registry, and deploy to common targets (Azure Web App for Containers, AWS ECS, GCP Cloud Run, Kubernetes).

## Project Structure
- **app/**: FastAPI application entry (`main.py`)
- **tests/**: Pytest suite
- **Dockerfile**: Containerizing the app
- **requirements.txt**: Dependencies
- **.github/workflows/**: CI/CD workflows

## Local Development
Install and run locally:

Windows (PowerShell):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

macOS/Linux (bash):

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Run tests and lint:

```bash
pytest -q
flake8 app
```

## Docker
Build and run the container:

```bash
docker build -t fastapi-sample:local .
docker run -p 8000:8000 fastapi-sample:local
```

Open http://localhost:8000 to verify.

## CI
Workflow: `.github/workflows/ci.yml`
- Runs on push/PR
- Python versions: 3.10, 3.11, 3.12
- Steps: pip install, flake8 lint, pytest

## Deployment Targets
Use the multi-target workflow: `.github/workflows/deploy.yml`. Choose one of:
- `azure-webapp`: Push to GHCR and deploy to Azure Web App (Linux container)
- `aws-ecs`: Push to ECR and force a new deployment on an existing ECS service
- `gcp-cloud-run`: Push to Artifact Registry and deploy to Cloud Run
- `kubernetes`: Push to GHCR, apply manifests in `kubernetes/`, and update the image

### Required GitHub Secrets
Create the secrets for the target you plan to deploy to. Do not commit credentials or `.env` files to the repo.

Azure:
- `AZURE_CREDENTIALS` (Service Principal JSON)
- `AZURE_WEBAPP_NAME` (Linux, container)

AWS:
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `AWS_ECR_REPOSITORY`, `AWS_ECS_CLUSTER`, `AWS_ECS_SERVICE`

GCP:
- `GCP_SA_KEY`, `GCP_PROJECT_ID`, `GCP_REGION`, `GCP_AR_REPOSITORY`, `CLOUD_RUN_SERVICE`

Kubernetes:
- `KUBE_CONFIG` (kubeconfig YAML)

### Azure Setup (once)
1. Create a resource group and Web App (Linux, container).
2. Create a Service Principal and assign `Contributor` to the resource group.
3. Add its JSON to `AZURE_CREDENTIALS` secret.
4. Set `AZURE_WEBAPP_NAME` to the Web App name.

### Optional: Use GHCR private images
Ensure your Web App can pull from GHCR. For private images, set container registry credentials in Azure (Username: your GitHub username, Password: a GitHub PAT with `write:packages` scope) or keep the image public.

## Notes
- Adjust `requirements.txt` as needed.
- You can extend or customize deployment targets (AKS/EKS/GKE via `kubectl`, Fly.io, Render, etc.).

## Multi-Target Deploy
Workflow: `.github/workflows/deploy.yml`

Run it manually from the Actions tab and choose `target`:
- `azure-webapp`: Push to GHCR and deploy to Azure Web App (Linux container)
- `aws-ecs`: Push to ECR and force a new deployment on an existing ECS service
- `gcp-cloud-run`: Push to Artifact Registry and deploy to Cloud Run
- `kubernetes`: Push to GHCR, apply manifests in `kubernetes/`, and update the image

### Trigger via GitHub CLI
Run the workflow with inputs using the GitHub CLI (`gh`):

```bash
gh workflow run deploy.yml -f target=azure-webapp -f image_tag=latest
gh workflow run deploy.yml -f target=aws-ecs -f image_tag=latest
gh workflow run deploy.yml -f target=gcp-cloud-run -f image_tag=latest
gh workflow run deploy.yml -f target=kubernetes -f image_tag=latest
```

### Required Secrets/Vars

Azure (same as above):
- `AZURE_CREDENTIALS` (JSON)
- `AZURE_WEBAPP_NAME`

AWS:
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- `AWS_ECR_REPOSITORY`: ECR repo name (e.g., `infra-lab`)
- `AWS_ECS_CLUSTER`, `AWS_ECS_SERVICE`: Existing ECS cluster/service to redeploy

GCP:
- `GCP_SA_KEY`: Service Account JSON with roles `roles/run.admin`, `roles/artifactregistry.writer`
- `GCP_PROJECT_ID`, `GCP_REGION`, `GCP_AR_REPOSITORY`: Artifact Registry repo name (e.g., `apps`)
- `CLOUD_RUN_SERVICE`: Name of the Cloud Run service

Kubernetes (generic):
- `KUBE_CONFIG`: The kubeconfig content for your cluster (paste YAML into the secret). The workflow writes this to `~/.kube/config`.

### Kubernetes Manifests
Included manifests:
- [k8s/deployment.yaml](k8s/deployment.yaml)
- [k8s/service.yaml](k8s/service.yaml)

The workflow runs:
- `kubectl apply -f k8s/`
- `kubectl set image deployment/infra-lab app=ghcr.io/<owner>/<repo>:<tag>`

If your cluster requires private image pull from GHCR, create an imagePullSecret and attach it to the default service account (or to the deployment):
```bash
kubectl create secret docker-registry ghcr-creds \
	--docker-server=ghcr.io \
	--docker-username=<github-username> \
	--docker-password=<github-personal-access-token-with-read:packages> \
	--docker-email=<email>

kubectl patch serviceaccount default \
	-p '{"imagePullSecrets":[{"name":"ghcr-creds"}]}'
```
Alternatively, add `imagePullSecrets` under `spec.template.spec` in [k8s/deployment.yaml](k8s/deployment.yaml).

### Example Setup Commands

AWS (ECR repo + ECS redeploy assumes task definition uses `:latest`):
```bash
# Create ECR repo (once)
aws ecr create-repository --repository-name infra-lab --region <region>

# Force redeploy (service already created)
aws ecs update-service \
	--cluster <cluster-name> \
	--service <service-name> \
	--force-new-deployment
```

GCP (Artifact Registry repo and Cloud Run service):
```bash
# Enable services
gcloud services enable run.googleapis.com artifactregistry.googleapis.com

# Create repository (once)
gcloud artifacts repositories create apps \
	--repository-format=docker \
	--location=<region> \
	--description="Docker images"

# First-time Cloud Run deploy (can be done from workflow thereafter)
gcloud run deploy <service-name> \
	--image=<region>-docker.pkg.dev/<project>/apps/<owner>/<repo>:latest \
	--region=<region> \
	--platform=managed \
	--allow-unauthenticated
```

### Image Tags
The workflow input `image_tag` defaults to `latest`. Ensure your ECS task definition, Cloud Run service, Azure Web App config, or Kubernetes deployment pulls the tag you deploy.

### Adding More Targets
We can add cloud-specific Kubernetes contexts:
- AKS: `azure/aks-set-context` after `azure/login`
- EKS: `aws-actions/amazon-eks-update-kubeconfig` after AWS credentials
- GKE: `gcloud container clusters get-credentials` after `setup-gcloud`
Or add platforms like Fly.io or Render.

### CI Lint/Test Configuration (optional)
- Flake8: add a `.flake8` file to configure style rules and exclusions.
- Pytest: use `pytest.ini` or `pyproject.toml` to set options (e.g., `-q`, test discovery patterns).

### Publish Checklist
- Secrets: kept only in GitHub Actions secrets; `.env` files ignored by [.gitignore](.gitignore).
- EOLs: normalized via [.gitattributes](.gitattributes) (LF for source, CRLF for Windows scripts).
- Sensitive files: keys/certs are ignored by [.gitignore](.gitignore).
- Images: consider whether GHCR images should be public or private.
- License: add a LICENSE if you plan to open-source (optional).
- Badges: add Actions status badges if desired (optional).

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Infrastructure as Code (Terraform)
See [terraform/README.md](terraform/README.md) for infrastructure setup using Terraform. Includes configurations for:
- Azure Web App for Containers
- AWS ECS (Fargate)
- GCP Cloud Run
- Kubernetes (via Terraform provider)

