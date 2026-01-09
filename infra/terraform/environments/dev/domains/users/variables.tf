# ============================================
# Users Domain - Variables
# ============================================

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "api_gateway_id" {
  description = "ID of the shared API Gateway"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the shared API Gateway"
  type        = string
}

variable "api_gateway_root_resource_id" {
  description = "Root resource ID of the shared API Gateway"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for DynamoDB"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Log level for Lambda functions"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "Log level must be DEBUG, INFO, WARN, or ERROR"
  }
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}
