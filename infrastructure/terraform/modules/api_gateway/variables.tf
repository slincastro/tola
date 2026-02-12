variable "name_prefix" {
  description = "Prefix to be used in naming the API Gateway resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "auth_enabled" {
  description = "Whether to enable Cognito authentication"
  type        = bool
  default     = false
}

variable "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool to use for authentication"
  type        = string
  default     = ""
}

variable "cognito_client_id" {
  description = "Client ID of the Cognito User Pool App client"
  type        = string
  default     = ""
}