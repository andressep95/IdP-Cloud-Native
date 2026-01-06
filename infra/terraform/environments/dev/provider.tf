# ============================================
# AWS Provider Configuration for LocalStack
# ============================================

provider "aws" {
  region = var.aws_region

  # LocalStack configuration
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null

  # Override endpoints for LocalStack
  endpoints {
    dynamodb       = var.use_localstack ? var.localstack_endpoint : null
    lambda         = var.use_localstack ? var.localstack_endpoint : null
    apigateway     = var.use_localstack ? var.localstack_endpoint : null
    iam            = var.use_localstack ? var.localstack_endpoint : null
    s3             = var.use_localstack ? var.localstack_endpoint : null
    cloudwatch     = var.use_localstack ? var.localstack_endpoint : null
    secretsmanager = var.use_localstack ? var.localstack_endpoint : null
    ssm            = var.use_localstack ? var.localstack_endpoint : null
  }

  # Skip credential validation for LocalStack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # Default tags (applied to all resources)
  default_tags {
    tags = var.common_tags
  }
}
