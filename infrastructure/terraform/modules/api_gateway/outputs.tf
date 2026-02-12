output "api_gateway_id" {
  description = "ID of the created API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_gateway_arn" {
  description = "ARN of the created API Gateway"
  value       = aws_apigatewayv2_api.this.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway's default stage"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "authorizer_id" {
  description = "ID of the JWT Authorizer, if authentication is enabled"
  value       = var.auth_enabled ? aws_apigatewayv2_authorizer.cognito[0].id : "N/A"
}