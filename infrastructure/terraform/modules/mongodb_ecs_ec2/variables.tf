variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name used for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "create_vpc" {
  description = "Whether to create a new VPC and subnets"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC when create_vpc is true"
  type        = string
  default     = "10.42.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use. If empty, first 2 AZs in the region are used"
  type        = list(string)
  default     = []
}

variable "existing_vpc_id" {
  description = "Existing VPC ID when create_vpc is false"
  type        = string
  default     = null
}

variable "existing_private_subnet_ids" {
  description = "Existing private subnet IDs when create_vpc is false"
  type        = list(string)
  default     = []
}

variable "existing_public_subnet_ids" {
  description = "Existing public subnet IDs when create_vpc is false"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 instance type for ECS container instances"
  type        = string
  default     = "t3.small"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "mongo_ebs_size_gb" {
  description = "Size in GB for MongoDB data EBS volume"
  type        = number
  default     = 50
}

variable "mongo_ebs_iops" {
  description = "IOPS for gp3 volume"
  type        = number
  default     = 3000
}

variable "mongo_ebs_throughput" {
  description = "Throughput for gp3 volume in MiB/s"
  type        = number
  default     = 125
}

variable "mongo_db_port" {
  description = "MongoDB port"
  type        = number
  default     = 27017
}

variable "mongo_root_username" {
  description = "MongoDB root username"
  type        = string
  sensitive   = true
}

variable "mongo_root_password" {
  description = "MongoDB root password"
  type        = string
  sensitive   = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 14
}

variable "app_allowed_cidrs" {
  description = "Optional CIDR blocks allowed into app SG for testing"
  type        = list(string)
  default     = []
}
