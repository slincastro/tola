provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Tola"
      Environment = "dev"
      Terraform   = "true"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.10.0"
    }
  }

  # In production, you'd use a remote backend like this:
  # backend "s3" {
  #   bucket         = "tola-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "tola-terraform-locks"
  #   encrypt        = true
  # }
}
