#!/bin/bash
# Script to deploy via Terraform

set -e

ENVIRONMENT=${1:-azure}
ACTION=${2:-plan}

case "$ENVIRONMENT" in
  azure|aws|gcp|kubernetes)
    cd "terraform/${ENVIRONMENT}"
    ;;
  *)
    echo "Usage: $0 {azure|aws|gcp|kubernetes} {plan|apply|destroy}"
    exit 1
    ;;
esac

case "$ACTION" in
  plan)
    terraform init || exit 1
    terraform plan || exit 1
    ;;
  apply)
    terraform init || exit 1
    terraform apply -auto-approve || exit 1
    ;;
  destroy)
    terraform destroy -auto-approve || exit 1
    ;;
  *)
    echo "Usage: $0 {azure|aws|gcp|kubernetes} {plan|apply|destroy}"
    exit 1
    ;;
esac
