# ============================================
# Shared - API Gateway REST API (V1)
# LocalStack Compatible
# ============================================

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "Main API Gateway for IdP platform"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.common_tags,
    {
      Name     = "${var.project_name}-api"
      Resource = "api-gateway"
    }
  )
}

# API Gateway Deployment
# NOTE: This will be created by domain modules with proper dependencies
# Each domain will create deployment with depends_on their methods

# Placeholder outputs for domains to use
locals {
  # Domains will create their own deployments
  dummy_deployment_id = "placeholder"
}
