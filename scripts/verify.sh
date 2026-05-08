#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"
TF_DIR="terraform/environments/$ENVIRONMENT"

terraform -chdir="$TF_DIR" init -upgrade=false >/dev/null
terraform -chdir="$TF_DIR" output

echo "Verification complete for $ENVIRONMENT"
