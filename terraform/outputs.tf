output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "api_url" {
  description = "API endpoint for serverless module"
  value       = var.enable_serverless ? module.app_serverless[0].api_endpoint : null
}

output "alb_dns_name" {
  description = "ALB DNS name for container module"
  value       = var.enable_containers ? module.app_containers[0].alb_dns_name : null
}

output "artifact_bucket" {
  description = "S3 artifact bucket name"
  value       = module.storage.artifact_bucket_name
}

output "alerts_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = module.observability.alerts_topic_arn
}
