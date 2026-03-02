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
  description = "MongoDB connection string used when ECS Mongo is disabled"
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

variable "lambda_enable_vpc" {
  description = "Whether Lambda should run inside VPC"
  type        = bool
  default     = true
}

variable "enable_ecs_mongo" {
  description = "Whether to deploy MongoDB on ECS EC2 with EBS"
  type        = bool
  default     = true
}

variable "create_vpc" {
  description = "Whether to create a VPC for MongoDB ECS resources"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block when create_vpc is true"
  type        = string
  default     = "10.42.0.0/16"
}

variable "existing_vpc_id" {
  description = "Existing VPC ID when create_vpc is false"
  type        = string
  default     = null
}

variable "existing_private_subnet_ids" {
  description = "Existing private subnets when create_vpc is false"
  type        = list(string)
  default     = []
}

variable "existing_public_subnet_ids" {
  description = "Existing public subnets when create_vpc is false"
  type        = list(string)
  default     = []
}

variable "mongo_instance_type" {
  description = "EC2 instance type for MongoDB ECS host"
  type        = string
  default     = "t3.small"
}

variable "mongo_ebs_size_gb" {
  description = "MongoDB EBS volume size in GB"
  type        = number
  default     = 50
}

variable "mongo_root_username" {
  description = "MongoDB root username for ECS-hosted Mongo"
  type        = string
  default     = "admin"
}

variable "mongo_root_password" {
  description = "MongoDB root password for ECS-hosted Mongo"
  type        = string
  sensitive   = true
}

variable "frontend_enabled" {
  description = "Whether to provision frontend static hosting on S3 + CloudFront"
  type        = bool
  default     = true
}

variable "frontend_bucket_name" {
  description = "S3 bucket name used for frontend static files"
  type        = string
  default     = null
}

variable "frontend_aliases" {
  description = "Optional custom domain aliases for CloudFront"
  type        = list(string)
  default     = []
}

variable "frontend_acm_certificate_arn" {
  description = "Optional ACM certificate ARN for CloudFront custom domains"
  type        = string
  default     = null
}

variable "frontend_price_class" {
  description = "CloudFront price class for frontend distribution"
  type        = string
  default     = "PriceClass_100"
}
