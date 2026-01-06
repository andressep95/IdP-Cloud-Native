# ============================================
# Variables - Backend Bootstrap
# ============================================

# Staging configuration
variable "staging_region" {
  description = "AWS Region for staging backend"
  type        = string
  default     = "us-east-1"
}

variable "staging_profile" {
  description = "AWS CLI profile for staging (optional)"
  type        = string
  default     = null
}

variable "staging_state_bucket_name" {
  description = "S3 bucket name for staging Terraform state"
  type        = string
  default     = "microservices-terraform-state-staging"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.staging_state_bucket_name))
    error_message = "Bucket name must be lowercase, alphanumeric, and hyphens only"
  }
}

variable "staging_lock_table_name" {
  description = "DynamoDB table name for staging state locking"
  type        = string
  default     = "microservices-terraform-lock-staging"
}

# Production configuration
variable "prod_region" {
  description = "AWS Region for prod backend"
  type        = string
  default     = "us-east-1"
}

variable "prod_profile" {
  description = "AWS CLI profile for prod (optional)"
  type        = string
  default     = null
}

variable "prod_state_bucket_name" {
  description = "S3 bucket name for prod Terraform state"
  type        = string
  default     = "microservices-terraform-state-prod"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.prod_state_bucket_name))
    error_message = "Bucket name must be lowercase, alphanumeric, and hyphens only"
  }
}

variable "prod_lock_table_name" {
  description = "DynamoDB table name for prod state locking"
  type        = string
  default     = "microservices-terraform-lock-prod"
}
