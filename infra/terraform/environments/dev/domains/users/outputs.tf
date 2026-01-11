# ============================================
# Users Domain - Outputs
# ============================================

# DynamoDB
output "dynamodb_table_name" {
  description = "Name of the users DynamoDB table"
  value       = module.users_table.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the users DynamoDB table"
  value       = module.users_table.table_arn
}

# IAM
output "users_write_role_arn" {
  value = module.users_write_iam.role_arn
}

output "users_write_role_name" {
  value = module.users_write_iam.role_name
}

# Lambda Functions
output "lambda_function_arns" {
  description = "ARNs of users Lambda functions"
  value = {
    users-create = module.users_create_lambda.function_arn
    # Add more as you implement them
  }
}

output "lambda_function_names" {
  description = "Names of users Lambda functions"
  value = {
    users-create = module.users_create_lambda.function_name
    # Add more as you implement them
  }
}

# API Gateway
output "api_gateway_stage_invoke_url" {
  description = "Invoke URL for the users API Gateway stage"
  value       = aws_api_gateway_stage.users.invoke_url
}

output "api_gateway_deployment_id" {
  description = "Deployment ID for the users API Gateway"
  value       = aws_api_gateway_deployment.users.id
}
