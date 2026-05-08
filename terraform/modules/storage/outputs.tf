output "artifact_bucket_name" {
  value = aws_s3_bucket.artifacts.id
}

output "logs_bucket_name" {
  value = aws_s3_bucket.logs.id
}

output "artifact_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
