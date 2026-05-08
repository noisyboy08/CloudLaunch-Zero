# Deployment Guide

1. Configure AWS credentials with sufficient IAM permissions.
2. Copy `.env.example` to `.env` and export values.
3. Run `./scripts/bootstrap.sh staging` once per account.
4. Deploy staging with `./scripts/deploy.sh staging`.
5. Promote by deploying production with `./scripts/deploy.sh production`.

For CI, use workflows under `.github/workflows`.
