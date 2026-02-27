locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# MongoDB Atlas Cluster
module "mongodb_atlas" {
  source = "../../modules/mongodb_atlas"

  project_name   = var.project_name
  environment    = var.environment
  org_id         = var.mongodb_atlas_org_id
  db_username    = var.mongodb_db_username
  db_password    = var.mongodb_db_password
  
  # Cluster configuration - adjust as needed
  cluster_name   = "${var.project_name}-cluster"
  cluster_tier   = "M0"  # Free tier - change for production
  cluster_region = "US_EAST_1"
  
  # For production, consider setting these to appropriate values
  allowed_cidr_blocks = ["0.0.0.0/0"]  # For development only, restrict this in production
}

# S3 Bucket for product images
module "s3_bucket" {
  source = "../../modules/s3"

  bucket_name = "${local.name_prefix}-product-images"
  environment = var.environment
}

# API Gateway
module "api_gateway" {
  source = "../../modules/api_gateway"

  name_prefix    = local.name_prefix
  environment    = var.environment
  lambda_arn     = module.lambda.lambda_function_arn
  lambda_name    = module.lambda.lambda_function_name
  auth_enabled   = var.auth_enabled
  cognito_user_pool_id = var.auth_enabled ? module.cognito[0].user_pool_id : ""
}

# Lambda function for API
module "lambda" {
  source = "../../modules/lambda"

  function_name  = "${local.name_prefix}-api"
  environment    = var.environment
  memory_size    = var.lambda_memory_size
  timeout        = var.lambda_timeout
  s3_bucket_name = module.s3_bucket.bucket_name
  s3_bucket_arn  = module.s3_bucket.bucket_arn
  
  environment_variables = {
    MONGODB_CONNECTION_STRING = module.mongodb_atlas.srv_connection_string
    S3_BUCKET_NAME            = module.s3_bucket.bucket_name
    AUTH_ENABLED              = var.auth_enabled
    MONGODB_DATABASE_NAME     = module.mongodb_atlas.database_name
  }
}

# Cognito User Pool (conditional creation)
module "cognito" {
  source = "../../modules/cognito"
  count  = var.auth_enabled ? 1 : 0

  user_pool_name = "${local.name_prefix}-users"
  environment    = var.environment
}