output "serverless_security_group_id" {
  value = aws_security_group.serverless.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail.id
}

output "secret_arn" {
  value = aws_secretsmanager_secret.app.arn
}
