# Troubleshooting

- `Error acquiring state lock`: confirm DynamoDB lock table exists and IAM allows `dynamodb:*` on lock table.
- `BucketAlreadyOwnedByYou` during bootstrap: safe to ignore; script is idempotent.
- Lambda API 500 errors: inspect `/aws/lambda/cloudlaunch-zero-<env>-api` logs.
- ECS unhealthy targets: confirm task listens on port `8080` and SG rules permit ALB -> ECS traffic.
- RDS connectivity failures: verify ECS tasks run in private subnets and use RDS SG.
