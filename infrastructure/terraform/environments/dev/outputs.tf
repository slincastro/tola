output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = module.api_gateway.api_gateway_url
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda.lambda_function_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for product images"
  value       = module.s3_bucket.bucket_name
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = var.auth_enabled ? module.cognito[0].user_pool_id : "Authentication disabled"
}

output "cognito_app_client_id" {
  description = "The ID of the Cognito App Client"
  value       = var.auth_enabled ? module.cognito[0].app_client_id : "Authentication disabled"
}