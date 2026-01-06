# ============================================
# Dev Environment - Outputs
# ============================================

output "users_table_name" {
  description = "Name of the Users DynamoDB table"
  value       = module.user_table.table_name
}

output "users_table_arn" {
  description = "ARN of the Users DynamoDB table"
  value       = module.user_table.table_arn
}

output "users_table_id" {
  description = "ID of the Users DynamoDB table"
  value       = module.user_table.table_id
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "using_localstack" {
  description = "Whether LocalStack is being used"
  value       = var.use_localstack
}

output "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  value       = var.use_localstack ? var.localstack_endpoint : "N/A"
}
