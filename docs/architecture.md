# Architecture

CloudLaunch Zero composes these Terraform modules:

- `vpc`: network boundary with public/private subnets and NAT
- `security`: GuardDuty, CloudTrail, IAM policy baseline, SGs, and Secrets Manager
- `storage`: encrypted S3 artifact/log buckets with lifecycle rules
- `app-serverless`: HTTP API, Lambda authorizer, Lambda API handler, DynamoDB
- `app-containers`: ECS Fargate service behind ALB, ECR, RDS PostgreSQL, ACM cert
- `observability`: CloudWatch dashboards, alarms, and SNS notifications
- `cost`: AWS Budgets and Cost Anomaly Detection

Both application patterns are active by default so teams can run mixed workloads.
