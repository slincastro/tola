aws_region                = "us-east-1" # Choose your preferred region
project_name              = "tola"
environment               = "dev"
mongodb_connection_string = ""
auth_enabled              = false # Set to true if you want to enable Cognito authentication
lambda_memory_size        = 512
lambda_timeout            = 15
lambda_enable_vpc         = true

# ECS on EC2 MongoDB configuration
enable_ecs_mongo    = true
create_vpc          = true
mongo_instance_type = "t3.small"
mongo_ebs_size_gb   = 50
mongo_root_username = "admin"
mongo_root_password = "replace-with-strong-password"

# Frontend static hosting (S3 + CloudFront)
frontend_enabled             = true
frontend_bucket_name         = null
frontend_aliases             = []
frontend_acm_certificate_arn = null
frontend_price_class         = "PriceClass_100"
