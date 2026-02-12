# Cognito User Pool
resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  # Username attributes and alias settings
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  
  # Email verification
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject = "Your verification code"
    email_message = "Your verification code is {####}."
  }
  
  # Password policy
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Schema attributes
  schema {
    name                = "merchant_id"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    string_attribute_constraints {
      min_length = 1
      max_length = 255
    }
  }

  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable             = true
    required            = false
    string_attribute_constraints {
      min_length = 1
      max_length = 255
    }
  }

  # Admin create user config (for development/testing)
  admin_create_user_config {
    allow_admin_create_user_only = var.environment == "dev" ? false : true
    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}."
      email_subject = "Your temporary Tola login credentials"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Tag the resource
  tags = {
    Environment = var.environment
    Name        = var.user_pool_name
  }
}

# App client for accessing Cognito User Pool
resource "aws_cognito_user_pool_client" "this" {
  name                         = "${var.user_pool_name}-client"
  user_pool_id                 = aws_cognito_user_pool.this.id
  generate_secret              = false
  refresh_token_validity       = 30
  access_token_validity        = 1
  id_token_validity            = 1
  
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # Explicit auth flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  
  # Read and write all user attributes
  read_attributes  = ["email", "email_verified", "custom:merchant_id", "custom:role"]
  write_attributes = ["email", "custom:merchant_id", "custom:role"]
  
  # No callback URLs required for API-only auth
  callback_urls    = []
  logout_urls      = []
  
  # No client-side authentication for API
  prevent_user_existence_errors = "ENABLED"
  supported_identity_providers  = ["COGNITO"]
}

# Domain for Cognito hosted UI (optional)
resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.user_pool_name}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.this.id
}