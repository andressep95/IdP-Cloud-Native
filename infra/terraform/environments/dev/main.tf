# ============================================
# Main - Development Environment
# Orchestrates: Shared Resources + Domains
# ============================================

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # LocalStack configuration
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null

  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # Override endpoints for LocalStack
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      apigateway     = var.localstack_endpoint
      apigatewayv2   = var.localstack_endpoint
      cloudformation = var.localstack_endpoint
      cloudwatch     = var.localstack_endpoint
      dynamodb       = var.localstack_endpoint
      ec2            = var.localstack_endpoint
      iam            = var.localstack_endpoint
      lambda         = var.localstack_endpoint
      route53        = var.localstack_endpoint
      s3             = var.localstack_endpoint
      secretsmanager = var.localstack_endpoint
      ses            = var.localstack_endpoint
      sns            = var.localstack_endpoint
      sqs            = var.localstack_endpoint
      ssm            = var.localstack_endpoint
      stepfunctions  = var.localstack_endpoint
      sts            = var.localstack_endpoint
    }
  }

  default_tags {
    tags = merge(
      var.common_tags,
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Repository  = "IdP-Cloud"
      }
    )
  }
}

# ============================================
# Data Sources
# ============================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================
# Local Variables
# ============================================

locals {
  environment  = var.environment
  project_name = var.project_name
  aws_region   = var.aws_region

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Repository  = "IdP-Cloud"
  }
}

# ============================================
# SHARED RESOURCES (API Gateway, VPC, etc)
# ============================================

module "shared" {
  source = "./shared"

  project_name = local.project_name
  environment  = local.environment
  aws_region   = local.aws_region
  common_tags  = local.common_tags
}

# ============================================
# DOMAIN: Users
# ============================================

module "users_domain" {
  source = "./domains/users"

  # Global config
  project_name = local.project_name
  environment  = local.environment
  aws_region   = local.aws_region
  common_tags  = local.common_tags

  # Shared resources
  api_gateway_id                = module.shared.api_gateway_id
  api_gateway_execution_arn     = module.shared.api_gateway_execution_arn
  api_gateway_root_resource_id  = module.shared.api_gateway_root_resource_id

  # Dev-specific config
  enable_deletion_protection = var.enable_deletion_protection
  log_level                  = var.log_level
}
