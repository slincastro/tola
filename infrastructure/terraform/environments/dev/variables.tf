variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "tola"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
}

variable "mongodb_connection_string" {
  description = "MongoDB Atlas connection string"
  type        = string
  sensitive   = true
  # This should be provided via .tfvars or environment variables
  # DO NOT hardcode this value
}

variable "auth_enabled" {
  description = "Whether authentication should be enabled"
  type        = bool
  default     = false
}

variable "lambda_memory_size" {
  description = "Memory allocation for Lambda functions"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 15
}