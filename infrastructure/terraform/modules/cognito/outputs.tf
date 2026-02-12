output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "app_client_id" {
  description = "ID of the Cognito User Pool App client"
  value       = aws_cognito_user_pool_client.this.id
}

output "hosted_ui_url" {
  description = "URL of the Cognito hosted UI for login"
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

# Get current AWS region
data "aws_region" "current" {}