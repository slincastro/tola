Tola – Product Orchestrator
Infrastructure Specification (Light / Development)
1. Overview

Tola is a Product Orchestrator that manages product catalogs for multiple merchants, allowing products to be published across multiple sales channels (e.g. Facebook, Instagram, Mercado Libre).

This light development specification prioritizes:

fast setup

low cost

minimal AWS footprint

real MongoDB behavior

The platform follows a serverless + event-ready architecture but keeps components to the minimum required to execute and validate the product.

2. Cloud Environment

Cloud Provider: AWS

Architecture Style: Serverless (no VPC)

Infrastructure as Code: Terraform (minimal modules)

3. Core Architecture (DEV)
Client (React)
   ↓ HTTPS
API Gateway (HTTP API)
   ↓
Lambda (FastAPI)
   ↓
MongoDB Atlas (M0)
   ↓
Amazon S3 (Images)

4. API Entry Layer
API Gateway

Amazon API Gateway

Type: HTTP API

Public endpoint (no custom domain)

CORS enabled (React support)

Default throttling (no custom limits)

Responsibilities:

Route HTTP requests

Forward validated requests to Lambda

(Optional) JWT validation when auth is enabled

5. Authentication (Development Mode)
Option A – Disabled (Early DEV)

Authentication bypassed

Merchant identity injected via headers

Used for rapid local and cloud testing

Option B – Minimal Authentication

Amazon Cognito

Single User Pool

No groups

Custom attributes:

custom:merchant_id

custom:role

JWT validation handled at API Gateway level.

Note: Authorization logic (what a merchant can do) remains in the API.

6. Compute Layer
Lambda API

AWS Lambda

Runtime: Python 3.11

Framework: FastAPI

Adapter: Mangum (ASGI → Lambda)

Memory: 512 MB

Timeout: 15 seconds

No VPC attachment

Responsibilities:

Product CRUD

Status transitions

Emitting domain events (future-ready)

Integrating with Mongo and S3

7. Database Layer (Mongo)
MongoDB (Primary Catalog Store)

MongoDB Atlas

Cluster tier: M0 (Free Tier)

Region: close to AWS Lambda region

Network:

IP allowlist: 0.0.0.0/0 (DEV only)

Authentication:

Username / password

Database name: tola-dev

Collections
products
{
  "_id": "product_123",
  "merchant_id": "merchant_456",
  "status": "READY",
  "canonical": {
    "name": "Product name",
    "description": "Description",
    "price": 10
  },
  "channels": {
    "instagram": {
      "status": "PUBLISHED",
      "external_id": "ig_123"
    }
  },
  "created_at": "ISO-8601",
  "updated_at": "ISO-8601"
}


Indexes:

merchant_id

status

merchants
{
  "_id": "merchant_456",
  "name": "Merchant name",
  "status": "ACTIVE"
}

8. Assets Storage
Product Images

Amazon S3

Single bucket (dev)

Private access

Upload/download via presigned URLs

Default S3-managed encryption

Only image references (URLs or keys) are stored in Mongo.

9. Product Lifecycle Model (Normalized)
Core Product Status
Status	Meaning
DRAFT	Incomplete, not publishable
READY	Complete, eligible for publication
ACTIVE	Published in at least one channel
INACTIVE	Soft-deactivated

Deletion is treated as an action, not a state.

10. Observability (Minimal)

Amazon CloudWatch

Lambda logs

Default metrics (invocations, errors, duration)

No alarms initially

11. Explicitly Excluded (DEV)
❌ VPC / Subnets / NAT Gateway
❌ AWS WAF
❌ Amazon DocumentDB
❌ Custom KMS keys
❌ CodePipeline / CodeBuild
❌ Custom domains
❌ High availability configuration