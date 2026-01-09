# ============================================
# Global Outputs - Development Environment
# ============================================

# Shared Resources
output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.shared.api_gateway_endpoint
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = module.shared.api_gateway_id
}

# Users Domain
output "users_dynamodb_table_name" {
  description = "Users DynamoDB table name"
  value       = module.users_domain.dynamodb_table_name
}

output "users_dynamodb_table_arn" {
  description = "Users DynamoDB table ARN"
  value       = module.users_domain.dynamodb_table_arn
}

output "users_iam_role_arn" {
  description = "Users IAM role ARN"
  value       = module.users_domain.iam_role_arn
}

output "users_lambda_function_arns" {
  description = "Users Lambda function ARNs"
  value       = module.users_domain.lambda_function_arns
}

output "users_api_endpoint" {
  description = "Users API Gateway invoke URL"
  value       = module.users_domain.api_gateway_stage_invoke_url
}
