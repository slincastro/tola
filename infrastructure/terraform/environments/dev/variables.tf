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

variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas public API key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas private API key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas organization ID"
  type        = string
}

variable "mongodb_db_username" {
  description = "MongoDB Atlas database username"
  type        = string
  default     = "tola-app-user"
}

variable "mongodb_db_password" {
  description = "MongoDB Atlas database password"
  type        = string
  sensitive   = true
}

# This variable is kept for backward compatibility but will be populated from the module output
variable "mongodb_connection_string" {
  description = "MongoDB Atlas connection string (populated from module output)"
  type        = string
  sensitive   = true
  default     = ""
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