# ============================================
# Shared Module - Outputs
# ============================================

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "api_gateway_endpoint" {
  description = "Endpoint URL of the API Gateway (stage created by domains)"
  value       = "Deployment and stage created by domain modules"
}

output "api_gateway_stage_name" {
  description = "Stage name of the API Gateway"
  value       = "dev"
}

output "api_gateway_stage_invoke_url" {
  description = "Full invoke URL for the API Gateway stage (created by domains)"
  value       = "Stage invoke URL will be available after domain deployment"
}

output "api_gateway_root_resource_id" {
  description = "Root resource ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}
