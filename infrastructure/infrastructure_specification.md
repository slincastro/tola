# Infrastructure Specification for Tola - Product Orchestrator Platform

## Overview

This document provides detailed specifications for creating the AWS infrastructure for the Tola platform using Terraform. Tola is a Product Orchestrator that manages catalogs for multiple merchants, where each merchant can have multiple products distributed across multiple sales channels.

## AWS Account Requirements

- AWS Account already enabled
- Appropriate IAM permissions for Terraform to create resources

## Infrastructure Components

### 1. Networking Layer

#### VPC Configuration

```terraform
resource "aws_vpc" "tola_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "tola-vpc"
    Environment = "${var.environment}"
    Project = "tola"
  }
}
```

- **Subnets**:
  - 2 Public subnets (across different AZs)
  - 2 Private subnets (across different AZs)
- **Internet Gateway**: To allow communication between VPC and internet
- **NAT Gateway**: For private subnets to access internet
- **Route Tables**: Separate route tables for public and private subnets

### 2. Security Layer

#### Web Application Firewall (WAF)

- Create a WAF web ACL with the following rules:
  - Rate-based limiting to prevent DDoS attacks
  - SQL injection protection
  - Cross-site scripting (XSS) protection
  - IP-based restrictions for admin access
  - Geo-restriction if needed

#### Security Groups

- **API Gateway Security Group**:
  - Allow HTTPS (443) inbound from anywhere
- **Lambda Security Group**:
  - Allow all outbound traffic
  - No inbound traffic except from API Gateway

### 3. Authentication & Authorization

#### Amazon Cognito

- **User Pool**:
  - Multi-tenant setup with merchant isolation
  - Email/username and password authentication
  - MFA support
  - Customizable user attributes to store merchant-specific data
- **Identity Pool**:
  - Connect with User Pool
  - Define IAM roles for authenticated and unauthenticated users
  - Set up fine-grained permissions for different user types (admin, merchant, etc.)

### 4. API Layer

#### API Gateway (HTTP API)

- **API Configuration**:
  - Regional endpoint
  - Custom domain with ACM certificate
  - API mappings and stages (dev, staging, prod)
- **Integration with Lambda**:
  - Proxy integration with Lambda functions
  - JWT Authorizer connected to Cognito
- **API Documentation**:
  - OpenAPI specification
  - API documentation using Swagger
- **Throttling and Quotas**:
  - Set appropriate rate limits per API key/client
  - Usage plans for different merchant tiers

### 5. Compute Layer

#### Lambda Functions

- **Runtime Environment**:
  - Python 3.9+ runtime
  - FastAPI framework with Mangum adapter
- **Configuration**:
  - Memory: Start with 512MB, adjust based on performance tests
  - Timeout: 30 seconds (adjustable based on API needs)
  - Concurrency: Reserved concurrency to ensure availability
- **Environment Variables**:
  - Database connection details
  - S3 bucket names
  - Logging level
  - Feature flags
- **Function Structure**:
  - Separate Lambda functions for different API domains or use a monolithic function with FastAPI routing
- **Layers**:
  - Shared libraries and dependencies in Lambda Layers

### 6. Data Storage Layer

#### Amazon DocumentDB (MongoDB-compatible)

- **Cluster Configuration**:
  - Instance Class: Start with `db.r5.large` (adjustable based on workload)
  - Number of Instances: Minimum 3 for high availability (1 primary, 2 replicas)
  - Engine Version: Latest supported MongoDB-compatible version
  - Storage: Starts at 10GB and auto-scales up to 64TB
  
- **Collections**:
  - **Products Collection**:
    - Document Structure:
      ```json
      {
        "merchantId": "string",
        "productId": "string",
        "name": "string",
        "description": "string",
        "status": "DRAFT | READY | ACTIVE | INACTIVE",
        "pricing": {...},
        "attributes": {...},
        "channelOverrides": {...},
        "imageUrls": ["string"],
        "createdAt": "date",
        "updatedAt": "date"
      }
      ```
    - Indexes:
      - Compound Index on `{merchantId: 1, productId: 1}` (unique)
      - Index on `{status: 1, createdAt: 1}`
      - Index on `{channelId: 1, updatedAt: 1}` (for queries by channel)
  
  - **Merchants Collection**:
    - Document Structure:
      ```json
      {
        "merchantId": "string",
        "name": "string",
        "details": {...},
        "createdAt": "date"
      }
      ```
    - Indexes:
      - Index on `{merchantId: 1}` (unique)
  
  - **Channels Collection**:
    - Document Structure:
      ```json
      {
        "channelId": "string",
        "merchantId": "string",
        "name": "string",
        "type": "string",
        "config": {...}
      }
      ```
    - Indexes:
      - Compound Index on `{channelId: 1, merchantId: 1}` (unique)

- **Security**:
  - TLS enabled for all connections
  - IAM authentication
  - Encryption at rest with AWS KMS
  - VPC security groups limiting access to application tier

- **Backup and Recovery**:
  - Automated daily snapshots
  - Ability to restore to point-in-time within backup retention period
  - Optional manual snapshots before significant changes

- **Monitoring and Performance**:
  - CloudWatch metrics integration
  - Performance Insights enabled
  - Profiler for query optimization

#### S3 Buckets

- **Product Images Bucket**:
  - Versioning enabled
  - Lifecycle policies for cost optimization
  - CORS configuration for web client uploads
  - Private access with presigned URLs
- **Logs Bucket**:
  - Store access logs and application logs
  - Lifecycle policy to archive or delete old logs
- **Security**:
  - Default encryption with AWS KMS
  - Appropriate bucket policies and IAM roles
  - Block public access settings enabled

### 7. Monitoring and Logging

#### CloudWatch

- **Logs**:
  - Lambda function logs
  - API Gateway access logs
  - WAF logs
  - Custom application logs
- **Metrics**:
  - Custom metrics for business KPIs
  - Standard Lambda, API Gateway, and DocumentDB metrics
- **Alarms**:
  - Error rate thresholds
  - Latency thresholds
  - Throttling alerts
  - Cost alerts
- **Dashboards**:
  - Operational dashboard
  - Business metrics dashboard

#### X-Ray

- Enable X-Ray tracing for:
  - API Gateway
  - Lambda functions
  - DocumentDB operations
- Create sampling rules appropriate for the application

### 8. CI/CD Pipeline

#### CodePipeline

- **Source Stage**: Connect to GitHub repository
- **Build Stage**:
  - Use CodeBuild to run tests
  - Build Lambda packages
  - Generate Terraform plans
- **Deploy Stage**:
  - Apply Terraform plans
  - Deploy Lambda functions
  - Update API Gateway configuration
- **Test Stage**:
  - Run integration tests
  - Run load tests in staging

#### Infrastructure as Code

- Use Terraform modules for reusability
- Store state in S3 with state locking
- Use workspaces for different environments (dev, staging, prod)

## Environment-Specific Configurations

### Development

- Smaller instance sizes and capacities
- Debugging features enabled
- Less strict security rules for testing

### Staging

- Production-like setup but with reduced capacity
- Complete security implementation
- Used for testing before production deployment

### Production

- Full capacity implementation
- Strict security rules
- High availability across multiple AZs
- Regular backup schedules

## Cost Optimization Strategies

- Lambda provisioned concurrency only for critical functions
- DocumentDB right-sized instances with ability to scale up/out as needed
- S3 lifecycle policies to archive infrequently accessed objects
- Reserved instances or Savings Plans for predictable workloads

## Security Best Practices

- Principle of least privilege for IAM roles
- KMS encryption for sensitive data
- Regular security audits and updates
- WAF rules updated based on emerging threats
- Parameter Store for sensitive configuration

## Scaling Considerations

- DocumentDB instance scaling for increasing workloads
- Lambda concurrency limits set appropriately
- API Gateway throttling to protect backend
- Cache frequently accessed data with ElastiCache

## Disaster Recovery Strategy

- Point-in-time recovery for DocumentDB
- S3 cross-region replication for critical data
- Regular testing of recovery procedures
- Documented RTO and RPO objectives

## Implementation Notes

1. Start with core infrastructure components (VPC, subnets, security groups)
2. Deploy data storage resources next (DocumentDB, S3)
3. Implement compute layer (Lambda functions)
4. Set up API Gateway and WAF
5. Configure Cognito for authentication
6. Implement monitoring and alerting
7. Set up CI/CD pipeline

## Future Considerations

- Container-based deployments using ECS or EKS for more complex workloads
- Event processing with EventBridge for advanced integration scenarios
- Global tables for multi-region deployments
- Enhanced analytics with Athena, QuickSight, or third-party tools

---

This specification serves as a guide for creating Terraform code to deploy the AWS infrastructure for the Tola platform. The implementation should follow AWS and Terraform best practices, with appropriate use of variables, modules, and state management.