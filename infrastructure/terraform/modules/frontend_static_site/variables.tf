variable "name_prefix" {
  description = "Name prefix used for resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "api_gateway_url" {
  description = "API Gateway invoke URL used as CloudFront origin"
  type        = string
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for frontend static files"
  type        = string
}

variable "aliases" {
  description = "Optional CloudFront aliases (custom domains)"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN for CloudFront aliases"
  type        = string
  default     = null
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}
