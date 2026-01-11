# Development Setup

## Prerequisites
- Python 3.10+
- Docker (for local container testing)
- Terraform 1.0+ (for infrastructure)
- Git and pre-commit

## Local Environment Setup

### 1. Clone and Install
```bash
git clone https://github.com/pirsquare/infra-lab.git
cd infra-lab
make install-deps
make install-hooks
```

### 2. Create Virtual Environment
Windows (PowerShell):
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

macOS/Linux:
```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Run Locally
```bash
uvicorn src.main:app --reload
```

Visit http://localhost:8000 and http://localhost:8000/docs for API docs.

## Testing

Run the test suite:
```bash
make test
```

With coverage:
```bash
pytest --cov=src tests/
```

## Linting and Formatting

Check for issues:
```bash
make lint
```

Auto-fix formatting:
```bash
make format
```

## Docker Local Testing

Build and run the container locally:
```bash
docker build -t fastapi-app:local .
docker run -p 8000:8000 fastapi-app:local
```

## Terraform Local Development

Validate Terraform:
```bash
terraform -chdir=terraform validate
```

Format Terraform:
```bash
terraform -chdir=terraform fmt -recursive
```

Plan a deployment (example):
```bash
terraform -chdir=terraform plan -var-file=terraform.tfvars.example
```

## Debugging

### Python
Use breakpoints with `pdb`:
```python
import pdb; pdb.set_trace()
```

Or use an IDE with debugger support (VS Code, PyCharm).

### Terraform
Enable debug logging:
```bash
export TF_LOG=DEBUG
terraform plan
```

## Pre-commit Hooks

Run hooks manually:
```bash
pre-commit run --all-files
```

Update hooks:
```bash
pre-commit autoupdate
```

## Common Tasks

| Task | Command |
|------|---------|
| Run tests | `make test` |
| Check style | `make lint` |
| Format code | `make format` |
| Build Docker | `docker build -t fastapi-app:local .` |
| Run locally | `uvicorn src.main:app --reload` |
| Validate Terraform | `make init target=kubernetes` |

## Troubleshooting

**Issue**: Tests fail with import errors
**Solution**: Ensure virtual environment is activated and dependencies installed:
```bash
pip install -r requirements.txt
```

**Issue**: Terraform state lock
**Solution**: Check for another terraform process and kill if needed. To force unlock (use with caution):
```bash
terraform -chdir=terraform force-unlock <LOCK_ID>
```

**Issue**: Docker build fails
**Solution**: Ensure `src/` and `requirements.txt` are in the build context and referenced correctly in the Dockerfile.
