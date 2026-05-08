locals {
  lambda_name              = "${var.app_name}-${var.environment}-api"
  authorizer_name          = "${var.app_name}-${var.environment}-authorizer"
  api_zip_path             = "${path.module}/lambda_functions/api_handler.zip"
  auth_zip_path            = "${path.module}/lambda_functions/authorizer.zip"
  is_prod                  = var.environment == "production"
  api_reserved_concurrency = local.is_prod ? 100 : 10
  log_retention_days       = local.is_prod ? 90 : 14
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

data "archive_file" "api_handler" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/api_handler"
  output_path = local.api_zip_path
}

data "archive_file" "authorizer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/authorizer"
  output_path = local.auth_zip_path
}

resource "aws_cloudwatch_log_group" "authorizer" {
  name              = "/aws/lambda/${local.authorizer_name}"
  retention_in_days = local.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "api_handler" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = local.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "authorizer" {
  function_name    = local.authorizer_name
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.authorizer.output_path
  source_code_hash = data.archive_file.authorizer.output_base64sha256
  timeout          = 5
  memory_size      = 256
  architectures    = ["arm64"]

  environment {
    variables = {
      API_TOKEN = var.api_token
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = var.lambda_security_ids
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.authorizer]

  tags = var.tags
}

resource "aws_lambda_function" "api_handler" {
  function_name                  = local.lambda_name
  role                           = aws_iam_role.lambda_exec.arn
  runtime                        = "nodejs20.x"
  handler                        = "index.handler"
  filename                       = data.archive_file.api_handler.output_path
  source_code_hash               = data.archive_file.api_handler.output_base64sha256
  timeout                        = 20
  memory_size                    = local.is_prod ? 1024 : 512
  architectures                  = ["arm64"]
  reserved_concurrent_executions = local.api_reserved_concurrency

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = var.lambda_security_ids
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [aws_cloudwatch_log_group.api_handler]

  tags = var.tags
}
