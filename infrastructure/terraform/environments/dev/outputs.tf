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

output "ecs_mongo_cluster_name" {
  description = "ECS cluster name for MongoDB on ECS EC2"
  value       = var.enable_ecs_mongo ? module.mongodb_ecs_ec2[0].ecs_cluster_name : null
}

output "ecs_mongo_service_name" {
  description = "ECS service name for MongoDB on ECS EC2"
  value       = var.enable_ecs_mongo ? module.mongodb_ecs_ec2[0].ecs_service_name : null
}

output "ecs_mongo_private_ip" {
  description = "Private IP for MongoDB ECS host instance when available"
  value       = var.enable_ecs_mongo ? module.mongodb_ecs_ec2[0].mongo_private_ip : null
}

output "ecs_mongo_connection_string_example" {
  description = "Example Mongo URI for workloads inside the VPC"
  value       = var.enable_ecs_mongo ? module.mongodb_ecs_ec2[0].mongo_connection_string_example : null
  sensitive   = true
}

output "ecs_mongo_private_ip_lookup_command" {
  description = "CLI command to fetch Mongo private IP if output is null during first apply"
  value       = var.enable_ecs_mongo ? module.mongodb_ecs_ec2[0].mongo_private_ip_lookup_command : null
}
