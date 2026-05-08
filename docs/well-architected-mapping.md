# AWS Well-Architected Mapping

- Security: GuardDuty, CloudTrail, IAM account policy, SG segmentation, encrypted storage
- Reliability: multi-AZ subnet design, ALB health checks, deployment circuit breaker, PITR DynamoDB
- Performance Efficiency: serverless auto-scaling, ECS Fargate managed scaling, CloudWatch telemetry
- Cost Optimization: AWS Budgets, anomaly monitor, lifecycle transitions for S3
- Operational Excellence: modular IaC, GitHub Actions plan/apply, scripted lifecycle operations
- Sustainability: right-sized defaults and lifecycle policies to reduce storage overhead
