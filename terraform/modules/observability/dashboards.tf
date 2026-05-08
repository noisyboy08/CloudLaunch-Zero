resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Invocations"
          view    = "timeSeries"
          region  = "us-east-1"
          metrics = var.lambda_function_name != null ? [["AWS/Lambda", "Invocations", "FunctionName", var.lambda_function_name]] : []
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "ECS CPU"
          view    = "timeSeries"
          region  = "us-east-1"
          metrics = var.ecs_cluster_name != null && var.ecs_service_name != null ? [["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]] : []
        }
      }
    ]
  })
}
