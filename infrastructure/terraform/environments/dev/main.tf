locals {
  name_prefix = "${var.project_name}-${var.environment}"
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

  name_prefix          = local.name_prefix
  environment          = var.environment
  lambda_arn           = module.lambda.lambda_function_arn
  lambda_name          = module.lambda.lambda_function_name
  auth_enabled         = var.auth_enabled
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
    MONGODB_CONNECTION_STRING = var.enable_ecs_mongo ? module.mongodb_ecs_ec2[0].mongo_connection_string_example : var.mongodb_connection_string
    S3_BUCKET_NAME            = module.s3_bucket.bucket_name
    AUTH_ENABLED              = var.auth_enabled
    MONGODB_DATABASE_NAME     = "admin"
  }
}

# Cognito User Pool (conditional creation)
module "cognito" {
  source = "../../modules/cognito"
  count  = var.auth_enabled ? 1 : 0

  user_pool_name = "${local.name_prefix}-users"
  environment    = var.environment
}

module "mongodb_ecs_ec2" {
  source = "../../modules/mongodb_ecs_ec2"
  count  = var.enable_ecs_mongo ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  create_vpc                  = var.create_vpc
  vpc_cidr                    = var.vpc_cidr
  existing_vpc_id             = var.existing_vpc_id
  existing_private_subnet_ids = var.existing_private_subnet_ids
  existing_public_subnet_ids  = var.existing_public_subnet_ids

  instance_type       = var.mongo_instance_type
  mongo_ebs_size_gb   = var.mongo_ebs_size_gb
  mongo_root_username = var.mongo_root_username
  mongo_root_password = var.mongo_root_password
}
