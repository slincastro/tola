variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 15
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for image storage"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for image storage"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
  sensitive   = true # Mark as sensitive to prevent values from showing in logs
}

variable "enable_vpc" {
  description = "Whether to attach Lambda to a VPC"
  type        = bool
  default     = false
}

variable "vpc_subnet_ids" {
  description = "Subnet IDs for Lambda VPC attachment"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for Lambda VPC attachment"
  type        = list(string)
  default     = []
}
