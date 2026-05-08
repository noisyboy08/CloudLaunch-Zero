# CloudLaunch Zero

CloudLaunch Zero is a production-focused Infrastructure as Code foundation for AWS built with Terraform. It deploys a secure, observable, and cost-aware platform using two application patterns in the same stack:

- Serverless runtime: `Lambda + API Gateway + DynamoDB`
- Container runtime: `ECS Fargate + ALB + RDS + ECR`

This repository is designed to be copy-pasteable for real environments and then extended by platform teams.

## What This Project Delivers

- Terraform AWS provider pinned to `~> 5.0`
- Remote state with `S3` backend and `DynamoDB` locking
- Reusable modules for networking, security, storage, workloads, observability, and cost governance
- Environment overlays for `staging` and `production`
- Deployment lifecycle scripts for bootstrap, deploy, verify, rollback, and destroy
- CI workflows for Terraform plan/apply gates

## Architecture Overview

CloudLaunch Zero composes these layers:

1. Foundation
   - VPC with public/private subnets across multiple AZs
   - Internet Gateway, route tables, and optional NAT egress for private subnets
2. Security and Governance
   - Security groups for ALB, ECS, Lambda, and RDS isolation
   - GuardDuty detector
   - CloudTrail organization-grade audit logging to encrypted S3
   - IAM account password policy baseline
   - Secrets Manager for application secret storage
3. Data and Artifact Storage
   - Encrypted/versioned S3 buckets for artifacts and logs
   - Lifecycle transitions to optimize long-term storage cost
4. Workload Patterns
   - Serverless API stack with Lambda authorizer and DynamoDB
   - Container stack with ECS Fargate behind ALB and PostgreSQL on RDS
5. Operations and FinOps
   - CloudWatch alarms and dashboard
   - SNS alerts to email
   - AWS Budgets and Cost Anomaly Detection

## Repository Layout

```text
cloudlaunch-zero/
  terraform/
    modules/
      vpc/
      security/
      storage/
      app-serverless/
      app-containers/
      observability/
      cost/
    environments/
      staging/
      production/
  scripts/
  docs/
  .github/workflows/
```

## Terraform Module Deep Dive

### `terraform/modules/vpc`

Creates the networking baseline:

- VPC CIDR and DNS hostnames support
- Public and private subnets across `az_count`
- Internet gateway
- Per-private-subnet route tables
- NAT gateways (controlled by `enable_nat_gateway`)

Primary outputs:

- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`

### `terraform/modules/security`

Implements account and runtime security controls:

- Security groups:
  - ALB ingress on `80`
  - ECS ingress from ALB on `8080`
  - RDS ingress from ECS on `5432`
  - Lambda egress-enabled SG
- GuardDuty detector with continuous findings
- CloudTrail with encrypted/versioned S3 storage and strict bucket policy
- Secrets Manager secret + seeded secret version
- IAM account password policy hardening

Primary outputs:

- SG IDs for serverless/containers
- CloudTrail bucket name
- Secret ARN

### `terraform/modules/storage`

Creates persistent object storage:

- Artifact bucket and logs bucket
- SSE encryption
- Versioning
- Lifecycle rules for transition/retention

Primary outputs:

- Artifact bucket name and ARN
- Logs bucket name

### `terraform/modules/app-serverless`

Deploys a complete serverless API path:

- Lambda execution role and attachments
- `archive_file` packaging for `api_handler` and `authorizer`
- Lambda authorizer with bearer token validation
- API Gateway HTTP API with custom authorizer route protection
- DynamoDB table with encryption and PITR enabled
- Lambda permissions for API Gateway invocation

Primary outputs:

- API endpoint URL
- API Lambda function name
- DynamoDB table name

### `terraform/modules/app-containers`

Deploys containerized runtime:

- ECS cluster with container insights
- CloudWatch log group for task logs
- Execution IAM role
- ALB + target group + listener
- ECS Fargate task definition and service with deployment circuit breaker
- RDS PostgreSQL in private subnets
- ECR repository with scanning on push
- ACM certificate request for runtime hostname

Primary outputs:

- ECS cluster/service names
- ALB DNS name
- Load balancer and target group ARN suffixes

### `terraform/modules/observability`

Sets up runtime monitoring and alerting:

- SNS topic and email subscription
- Lambda error alarm
- ECS high CPU alarm
- ALB 5xx alarm
- CloudWatch dashboard for Lambda and ECS widgets

Primary outputs:

- Alerts topic ARN
- Dashboard name

### `terraform/modules/cost`

Enforces spend awareness:

- Cost anomaly monitor (service dimension)
- Anomaly subscription with email notifications
- Monthly budget with threshold notifications

Primary outputs:

- Anomaly monitor ARN
- Monthly budget name

## Environments and State Strategy

Environment overlays:

- `terraform/environments/staging`
- `terraform/environments/production`

Both use remote state backend:

- S3 bucket: `cloudlaunch-zero-tfstate-us-east-1`
- State lock table: `cloudlaunch-zero-tflock`
- Region: `us-east-1`

State file keys:

- `staging/terraform.tfstate`
- `production/terraform.tfstate`

## Input Variables (Root Stack)

Key root variables in `terraform/variables.tf`:

- `app_name` (default `cloudlaunch-zero`)
- `environment`
- `region` (default `us-east-1`)
- `vpc_cidr`
- `az_count`
- `enable_nat_gateway`
- `enable_serverless`
- `enable_containers`
- `container_image`
- `db_username`
- `db_password` (sensitive)
- `api_token` (sensitive)
- `alert_email`
- `tags`

## Prerequisites

- AWS account with permissions for VPC, IAM, ECS, Lambda, API Gateway, RDS, CloudWatch, Budgets, and Cost Explorer APIs
- AWS credentials configured locally (`aws configure` or environment variables)
- Terraform CLI `>= 1.5.0`
- Bash shell for scripts under `scripts/`

## Quick Start

1. Clone and move into the repository:

```bash
cd cloudlaunch-zero
```

2. Copy environment template:

```bash
cp .env.example .env
```

3. Bootstrap backend infrastructure:

```bash
./scripts/bootstrap.sh staging
```

4. Deploy staging:

```bash
./scripts/deploy.sh staging
```

5. Verify outputs:

```bash
./scripts/verify.sh staging
```

6. Deploy production when ready:

```bash
./scripts/deploy.sh production
```

## Deployment Commands

Using scripts:

```bash
./scripts/test.sh
./scripts/bootstrap.sh staging
./scripts/deploy.sh staging
./scripts/verify.sh staging
./scripts/rollback.sh staging
./scripts/destroy.sh staging
```

Using PowerShell on Windows:

```powershell
Set-Location .\cloudlaunch-zero
.\scripts\setup-provider-mirror.ps1
.\scripts\test.ps1
```

If script execution is restricted on your machine:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

Using `Makefile`:

```bash
make fmt
make init ENV=staging
make validate ENV=staging
make test
make plan ENV=staging
make apply ENV=staging
```

## CI/CD Workflows

- `terraform-plan.yml`
  - Triggers on pull requests for Terraform/workflow changes
  - Runs init, fmt check, validate, and plan for both staging and production
- `terraform-apply.yml`
  - Manual dispatch workflow
  - Applies selected environment (`staging` or `production`)
- `terraform-validate.yml`
  - Runs fmt check + `init -backend=false` + validate for both environments
  - Gives deterministic static verification even without backend credentials

## GitHub and Vercel Deployment

### GitHub (recommended for this repository)

This repository is fully compatible with GitHub + GitHub Actions.

```powershell
Set-Location C:\Users\udayd\OneDrive\Desktop\CloudLaunch\cloudlaunch-zero
git init
git add .
git commit -m "Initial commit: cloudlaunch-zero infrastructure baseline"
gh repo create cloudlaunch-zero --public --source . --remote origin --push
```

After push, configure two pieces of GitHub config before running apply workflows.

GitHub Actions Variables (per `staging` and `production` environment):

- `AWS_DEPLOY_ROLE_ARN` — IAM role ARN for OIDC trust

GitHub Actions Secrets (per environment):

- `ALERT_EMAIL`
- `API_TOKEN`
- `DB_PASSWORD`

The IAM role must trust GitHub OIDC. Example trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com" },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:*"
      }
    }
  }]
}
```

This avoids long-lived AWS keys entirely.

### Vercel (important note)

Vercel deploys web applications, while this repository is Terraform infrastructure code for AWS.
Use GitHub Actions in this repo for infrastructure deployment.

If you also want a Vercel-hosted frontend, create a separate frontend app repo and deploy that app to Vercel, while this repo continues to provision AWS infrastructure.

## Security and Operations Notes

- Replace sample values in `terraform.tfvars` before real deployments
- Use real secret delivery via CI secrets or secret manager injection
- Restrict CIDR and SG ingress further for organization policy
- For production, consider:
  - WAF on ALB/API
  - RDS Multi-AZ
  - Custom KMS CMKs for stronger key governance
  - Private hosted zones and DNS validation records for ACM

## Verification Status

Verified locally using `scripts/test.ps1`:

- `terraform fmt -recursive -check`: passes
- `terraform init -backend=false`: succeeds for `staging` and `production`
- `terraform validate`: succeeds for `staging` and `production`
- Smoke `terraform plan` reaches resource generation; only blocks on real AWS credentials (expected)

CI workflows that protect every merge:

- `terraform-validate.yml`: fmt + init + validate for both environments
- `terraform-plan.yml`: OIDC AWS auth + plan against real backend per environment
- `terraform-apply.yml`: manual dispatch + OIDC + environment approval gate
- `security-scan.yml`: Trivy IaC + TFLint + Gitleaks scheduled and on PR

Run locally (Windows PowerShell):

```powershell
Set-Location .\cloudlaunch-zero
.\scripts\setup-provider-mirror.ps1
.\scripts\test.ps1
```

Run locally (macOS/Linux with Docker):

```bash
cd cloudlaunch-zero
./scripts/test.sh
```

## Production Hardening Already Applied

- RDS: Multi-AZ, deletion protection, IAM auth, performance insights, Postgres logs export, final snapshot for production
- ECS: target-tracking autoscaling on CPU and memory, health checks, deployment circuit breaker, X-Ray tracing, ARM64 Graviton Lambda
- Lambda: reserved concurrency, X-Ray tracing, CloudWatch log retention, memory tuning per environment
- ALB: drop invalid headers, deletion protection in production
- CI: OIDC for AWS auth (no long-lived keys), per-environment approvals, Trivy/TFLint/Gitleaks scans, fmt-validate pipeline
- Tooling: pre-commit config (`terraform_fmt`, `terraform_validate`, `tflint`, `trivy`, `gitleaks`)

## Optional Next Hardening (Not Required for First Deploy)

- Add HTTPS listener and ACM DNS validation once a real domain is wired
- Add WAF in front of ALB and API Gateway
- Switch S3/RDS/DynamoDB encryption from `AES256` to customer-managed KMS keys
- Add VPC Flow Logs and AWS Config conformance packs
- Add CloudFront in front of ALB for edge caching
