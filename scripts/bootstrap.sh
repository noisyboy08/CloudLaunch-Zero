#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-staging}"
REGION="${AWS_REGION:-us-east-1}"
STATE_BUCKET="${TF_STATE_BUCKET:-cloudlaunch-zero-tfstate-us-east-1}"
LOCK_TABLE="${TF_LOCK_TABLE:-cloudlaunch-zero-tflock}"

if [[ "$REGION" == "us-east-1" ]]; then
  aws s3api create-bucket \
    --bucket "$STATE_BUCKET" \
    --region "$REGION" 2>/dev/null || true
else
  aws s3api create-bucket \
    --bucket "$STATE_BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration "LocationConstraint=$REGION" 2>/dev/null || true
fi

aws s3api put-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$STATE_BUCKET" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name "$LOCK_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region "$REGION" 2>/dev/null || true

echo "Bootstrap completed for $ENVIRONMENT in $REGION"
