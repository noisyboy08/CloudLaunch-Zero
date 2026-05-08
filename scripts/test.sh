#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_VERSION="${TF_VERSION:-1.7.5}"
ENVIRONMENTS=("staging" "production")

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required for scripts/test.sh but was not found."
  echo "Install Docker Desktop, then rerun this script."
  exit 1
fi

run_tf() {
  docker run --rm \
    -v "${ROOT_DIR}:/workspace" \
    -w /workspace \
    "hashicorp/terraform:${TF_VERSION}" "$@"
}

echo "==> Terraform fmt check"
run_tf -chdir=terraform fmt -recursive -check

for env in "${ENVIRONMENTS[@]}"; do
  echo "==> Terraform init (backend disabled): ${env}"
  run_tf -chdir="terraform/environments/${env}" init -backend=false

  echo "==> Terraform validate: ${env}"
  run_tf -chdir="terraform/environments/${env}" validate
done

echo "All static Terraform checks passed for: ${ENVIRONMENTS[*]}"
