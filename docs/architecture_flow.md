# Architecture Flow

```mermaid

flowchart LR
    %% Client Layer
    Client["Client (React / Web / Mobile)"]

    %% Edge / Entry
    APIGW["API Gateway (HTTP API)"]
    WAF["AWS WAF"]
    Cognito["Amazon Cognito"]

    %% Compute
    Lambda["AWS Lambda\n(FastAPI + Mangum)"]

    %% Data & Events
    DynamoDB["DynamoDB\n(Document Catalog)"]
    S3["Amazon S3\n(Product Images)"]

    %% Flow
    Client -->|HTTPS| WAF
    WAF --> APIGW
    APIGW -->|JWT Authorizer| Cognito
    Cognito --> APIGW
    APIGW --> Lambda

    Lambda -->|CRUD| DynamoDB
    Lambda -->|Upload / Read| S3
