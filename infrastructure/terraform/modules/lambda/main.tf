# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy document for S3 access
data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }
}

# IAM policy for S3 access
resource "aws_iam_policy" "s3_access" {
  name        = "${var.function_name}-s3-access"
  description = "Allow Lambda function to access S3 bucket"
  policy      = data.aws_iam_policy_document.s3_access.json
}

# Attach S3 access policy to Lambda role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Placeholder Lambda function with a simple Python handler
# In a real project, you would deploy your actual code from a zip file or container
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.handler"
  runtime       = "python3.10"  # Changed from python3.11 to supported version
  memory_size   = var.memory_size
  timeout       = var.timeout

  # In a real project, replace this with your actual deployment package
  filename      = data.archive_file.empty_lambda.output_path
  source_code_hash = data.archive_file.empty_lambda.output_base64sha256

  environment {
    variables = var.environment_variables
  }
}

# Create an empty Lambda deployment package for placeholder purposes
data "archive_file" "empty_lambda" {
  type        = "zip"
  output_path = "/tmp/empty_lambda.zip"

  source {
    content  = <<EOF
import json

def handler(event, context):
    print("Received event:", json.dumps(event))
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': 'Tola API placeholder response',
            'input': event
        })
    }
EOF
    filename = "main.py"
  }
}

# Lambda function URL for direct invocation (optional, as we're using API Gateway)
resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"  # For development only, use "AWS_IAM" in production
}

# CloudWatch Log Group for Lambda logs with 30-day retention
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 30
}