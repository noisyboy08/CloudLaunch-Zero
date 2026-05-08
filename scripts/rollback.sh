#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"
TF_DIR="terraform/environments/$ENVIRONMENT"

terraform -chdir="$TF_DIR" init
terraform -chdir="$TF_DIR" apply -refresh-only -auto-approve -var-file=terraform.tfvars

echo "Rollback reconciliation completed for $ENVIRONMENT"
