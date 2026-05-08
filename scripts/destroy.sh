#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"
TF_DIR="terraform/environments/$ENVIRONMENT"

terraform -chdir="$TF_DIR" init
terraform -chdir="$TF_DIR" destroy -var-file=terraform.tfvars -auto-approve

echo "Destroy completed for $ENVIRONMENT"
