# ============================================
# Users Domain - Lambda Functions
# From: spec/domains/users/infrastructure/compute.yaml
# ============================================

# ============================================
# Lambda: users-create
# Use Case: UC-USERS-001
# API Operation: createUser
# ============================================

module "users_create_lambda" {
  source = "../../../../modules/lambda"

  function_name    = "users-create"
  filename         = abspath("${path.root}/../../../../lambda/users/create-user/function.zip")
  source_code_hash = fileexists(abspath("${path.root}/../../../../lambda/users/create-user/function.zip")) ? filebase64sha256(abspath("${path.root}/../../../../lambda/users/create-user/function.zip")) : null

  role_arn     = module.users_write_iam.role_arn
  handler      = "bootstrap"
  runtime      = "provided.al2023"
  architecture = "arm64"

  # Resources from spec
  memory_size                    = local.lambda_configs["users-create"].memory_size
  timeout                        = local.lambda_configs["users-create"].timeout
  reserved_concurrent_executions = local.lambda_configs["users-create"].reserved_concurrent_executions

  # Environment variables from spec
  environment_variables = {
    SECRET_NAME = module.users_secrets.secret_name
    AWS_REGION  = var.aws_region
  }

  # Monitoring from spec
  xray_tracing_enabled = local.lambda_configs["users-create"].xray_enabled
  log_retention_days   = local.lambda_configs["users-create"].log_retention_days
  create_log_group     = false # Disabled for LocalStack

  # Error alarm from spec
  create_error_alarm       = false # Disabled for LocalStack
  error_threshold          = local.lambda_configs["users-create"].error_threshold
  error_period             = local.lambda_configs["users-create"].error_period
  error_evaluation_periods = local.lambda_configs["users-create"].error_evaluation_periods

  # Duration alarm from spec
  create_duration_alarm       = false # Disabled for LocalStack
  duration_threshold          = local.lambda_configs["users-create"].duration_threshold
  duration_period             = local.lambda_configs["users-create"].duration_period
  duration_evaluation_periods = local.lambda_configs["users-create"].duration_evaluation_periods

  environment = var.environment
  tags = merge(
    var.common_tags,
    {
      Domain       = local.domain_name
      UseCase      = local.lambda_configs["users-create"].use_case
      ApiOperation = local.lambda_configs["users-create"].api_operation
      SpecFile     = "spec/domains/users/infrastructure/compute.yaml"
    }
  )
}

# ============================================
# API Gateway Integration: users-create
# POST /users
# ============================================

# Create /users resource
resource "aws_api_gateway_resource" "users" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "users"
}

# Create POST method on /users
resource "aws_api_gateway_method" "users_create" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda integration for POST /users
resource "aws_api_gateway_integration" "users_create" {
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.users_create.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.users_create_lambda.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "users_create_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.users_create_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/POST/users"
}

# ============================================
# API Gateway Deployment & Stage
# ============================================

resource "aws_api_gateway_deployment" "users" {
  rest_api_id = var.api_gateway_id

  triggers = {
    # Redeploy when methods change
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.users_create.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.users_create,
    aws_api_gateway_integration.users_create,
  ]
}

resource "aws_api_gateway_stage" "users" {
  deployment_id = aws_api_gateway_deployment.users.id
  rest_api_id   = var.api_gateway_id
  stage_name    = var.environment

  tags = var.common_tags
}

# ============================================
# FUTURE: Add more Lambda functions here
# ============================================
# - users-get    (UC-USERS-002) - GET /users/{userId}
# - users-list   (UC-USERS-003) - GET /users
# - users-update (UC-USERS-004) - PATCH /users/{userId}
# - users-delete (UC-USERS-005) - DELETE /users/{userId}
