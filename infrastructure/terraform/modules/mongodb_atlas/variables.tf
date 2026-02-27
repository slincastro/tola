variable "project_name" {
  description = "The name of the MongoDB Atlas project"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "org_id" {
  description = "MongoDB Atlas organization ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas cluster"
  type        = string
  default     = "tola-cluster"
}

variable "cluster_tier" {
  description = "The tier of the MongoDB Atlas cluster (M0, M2, M5, etc.)"
  type        = string
  default     = "M0" # Free tier
}

variable "cluster_region" {
  description = "The region where the MongoDB Atlas cluster will be provisioned"
  type        = string
  default     = "US_EAST_1"
}

variable "mongodb_version" {
  description = "MongoDB version for the cluster"
  type        = string
  default     = "5.0"
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "tola-db"
}

variable "db_username" {
  description = "Username for MongoDB database access"
  type        = string
  default     = "tola-app-user"
}

variable "db_password" {
  description = "Password for MongoDB database access"
  type        = string
  sensitive   = true
}

variable "ip_whitelist" {
  description = "List of IP addresses to whitelist for database access"
  type        = list(object({
    ip_address = string
    comment    = string
  }))
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks to whitelist"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow access from anywhere (not recommended for production)
}

variable "backup_enabled" {
  description = "Enable backups for the cluster"
  type        = bool
  default     = false # Set to true for paid tiers
}