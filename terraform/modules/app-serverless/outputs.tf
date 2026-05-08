output "api_endpoint" {
  value = aws_apigatewayv2_api.http.api_endpoint
}

output "lambda_function_name" {
  value = aws_lambda_function.api_handler.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.app.name
}
