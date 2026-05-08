#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"
TF_DIR="terraform/environments/$ENVIRONMENT"

terraform -chdir="$TF_DIR" init
terraform -chdir="$TF_DIR" fmt -recursive
terraform -chdir="$TF_DIR" validate
terraform -chdir="$TF_DIR" plan -var-file=terraform.tfvars -out=tfplan
terraform -chdir="$TF_DIR" apply -auto-approve tfplan

echo "Deployment successful for $ENVIRONMENT"
