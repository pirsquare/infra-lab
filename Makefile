.PHONY: help init plan apply destroy test lint format clean install-hooks

help:
	@echo "Available targets:"
	@echo "  make install-deps       - Install Python and Terraform dependencies"
	@echo "  make install-hooks      - Install pre-commit hooks"
	@echo "  make test               - Run tests"
	@echo "  make lint               - Run linters (flake8, tflint, tfsec)"
	@echo "  make format             - Format code (black, isort, terraform fmt)"
	@echo "  make init               - Initialize Terraform (target=<env>)"
	@echo "  make plan               - Plan Terraform deployment (target=<env>)"
	@echo "  make apply              - Apply Terraform deployment (target=<env>)"
	@echo "  make destroy            - Destroy Terraform deployment (target=<env>)"
	@echo "  make clean              - Clean build artifacts and caches"
	@echo "  make docs               - Generate Terraform documentation"

install-deps:
	pip install -r requirements.txt
	cd terraform && terraform init

install-hooks:
	pre-commit install
	@echo "Pre-commit hooks installed"

test:
	pytest -v

lint:
	flake8 src tests
	cd terraform && tflint -r all
	cd terraform && tfsec

format:
	black src tests
	isort src tests
	cd terraform && terraform fmt -recursive

init:
	@if [ -z "$(target)" ]; then echo "Usage: make init target=<azure|aws|gcp|kubernetes>"; exit 1; fi
	terraform -chdir=terraform init

plan:
	@if [ -z "$(target)" ]; then echo "Usage: make plan target=<azure|aws|gcp|kubernetes>"; exit 1; fi
	terraform -chdir=terraform plan -var="target=$(target)"

apply:
	@if [ -z "$(target)" ]; then echo "Usage: make apply target=<azure|aws|gcp|kubernetes>"; exit 1; fi
	terraform -chdir=terraform apply -var="target=$(target)"

destroy:
	@if [ -z "$(target)" ]; then echo "Usage: make destroy target=<azure|aws|gcp|kubernetes>"; exit 1; fi
	terraform -chdir=terraform destroy -var="target=$(target)"

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type d -name .pytest_cache -exec rm -rf {} +
	find . -type d -name .terraform -exec rm -rf {} +
	rm -f .terraform.lock.hcl *.tfstate *.tfstate.*

docs:
	terraform -chdir=terraform fmt -recursive
	@echo "Terraform documentation generated"
