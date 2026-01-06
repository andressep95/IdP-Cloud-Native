# ============================================
# Dev Environment - Input Variables
# Define QUÉ necesita el environment para funcionar
# ============================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev"], var.environment)
    error_message = "Environment must be dev."
  }
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "idp"
}

# LocalStack configuration
variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

variable "use_localstack" {
  description = "Whether to use LocalStack"
  type        = bool
  default     = true
}


# Variables específicas del environment
variable "enable_deletion_protection" {
  description = "Enable deletion protection (typically true for prod)"
  type        = bool
  default     = false # Dev: allow deletion
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "DEBUG" # More verbose in dev
}

# Tags comunes del environment
variable "common_tags" {
  description = "Common tags for all resources in this environment"
  type        = map(string)
  default     = {}
}
