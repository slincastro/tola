# Tola Infrastructure

This repository contains Terraform configurations for deploying the Tola Product Orchestrator infrastructure on AWS.

## Architecture Overview

Tola uses a serverless architecture on AWS with the following components:

- **API Gateway**: HTTP API for receiving and routing HTTP requests
- **Lambda**: Python-based API using FastAPI framework
- **S3**: Storage for product images
- **Cognito**: (Optional) Authentication for API access
- **MongoDB Atlas**: External database service for product data (not managed by Terraform)

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or later)
2. [AWS CLI](https://aws.amazon.com/cli/) installed and configured with appropriate credentials
3. A MongoDB Atlas account with a cluster set up
4. MongoDB connection string

## Project Structure

```
terraform/
├── environments/
│   └── dev/                  # Development environment configuration
│       ├── main.tf           # Main Terraform configuration
│       ├── outputs.tf        # Output values
│       ├── providers.tf      # Provider configuration
│       └── variables.tf      # Input variables
├── modules/
│   ├── api_gateway/          # API Gateway module
│   ├── cognito/              # Cognito User Pool module
│   ├── lambda/               # Lambda function module
│   └── s3/                   # S3 bucket module
└── README.md                 # This file
```

## Deployment Instructions

### Step 1: Configure Environment Variables

Create a `terraform.tfvars` file in the `environments/dev` directory with the following content:

```hcl
aws_region = "us-east-1"  # Choose your preferred region
project_name = "tola"
environment = "dev"
mongodb_connection_string = "mongodb+srv://username:password@your-cluster.mongodb.net/tola-dev?retryWrites=true&w=majority"
auth_enabled = false  # Set to true if you want to enable Cognito authentication
```

### Step 2: Initialize Terraform

```bash
cd infrastructure/terraform/environments/dev
terraform init
```

### Step 3: Review the Deployment Plan

```bash
terraform plan
```

Review the changes that Terraform will make to your infrastructure.

### Step 4: Apply the Configuration

```bash
terraform apply
```

Type 'yes' when prompted to confirm the deployment.

### Step 5: Access Your Infrastructure

After successful deployment, Terraform will output important information about your infrastructure, including:

- API Gateway URL
- S3 bucket name
- Lambda function name
- Cognito User Pool ID and client ID (if authentication is enabled)

## Managing Different Environments

This setup supports multiple environments. To create a new environment (e.g., production):

1. Copy the `dev` directory to a new directory (e.g., `prod`)
2. Update the variables in the new environment's `terraform.tfvars` file
3. Follow the deployment steps for the new environment

## Cleaning Up

To destroy all resources created by Terraform:

```bash
cd infrastructure/terraform/environments/dev
terraform destroy
```

Type 'yes' when prompted to confirm.

## Additional Notes

- For production environments, consider enabling a remote backend for state storage (e.g., S3 with DynamoDB for locking).
- Update the MongoDB Atlas IP allowlist if you're restricting access by IP.
- The Lambda function includes a placeholder implementation. Replace it with your actual application code.
- The Lambda function uses Python 3.10 runtime, which is the latest version supported by AWS Lambda at the time of writing.
- The Cognito configuration includes email verification and supports custom attributes for merchant_id and role. The configuration uses verification_message_template instead of auto_verification_email.

## Security Considerations

- In development, authentication may be disabled for simplicity, but it should be enabled in production.
- S3 bucket policies are configured for development purposes. For production, consider stricter policies.
- API Gateway CORS settings allow all origins in development. Restrict this in production.