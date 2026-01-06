# ============================================
# Outputs - Backend Bootstrap
# ============================================

# Staging outputs
output "staging_state_bucket_name" {
  description = "Name of the S3 bucket for staging Terraform state"
  value       = aws_s3_bucket.terraform_state_staging.id
}

output "staging_state_bucket_arn" {
  description = "ARN of the S3 bucket for staging Terraform state"
  value       = aws_s3_bucket.terraform_state_staging.arn
}

output "staging_lock_table_name" {
  description = "Name of the DynamoDB table for staging state locking"
  value       = aws_dynamodb_table.terraform_state_lock_staging.name
}

output "staging_lock_table_arn" {
  description = "ARN of the DynamoDB table for staging state locking"
  value       = aws_dynamodb_table.terraform_state_lock_staging.arn
}

# Production outputs
output "prod_state_bucket_name" {
  description = "Name of the S3 bucket for prod Terraform state"
  value       = aws_s3_bucket.terraform_state_prod.id
}

output "prod_state_bucket_arn" {
  description = "ARN of the S3 bucket for prod Terraform state"
  value       = aws_s3_bucket.terraform_state_prod.arn
}

output "prod_lock_table_name" {
  description = "Name of the DynamoDB table for prod state locking"
  value       = aws_dynamodb_table.terraform_state_lock_prod.name
}

output "prod_lock_table_arn" {
  description = "ARN of the DynamoDB table for prod state locking"
  value       = aws_dynamodb_table.terraform_state_lock_prod.arn
}

# ============================================
# Backend Configuration Snippets
# ============================================

output "staging_backend_config" {
  description = "Backend configuration snippet for staging environment"
  value       = <<-EOT
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state_staging.id}"
    key            = "microservices/terraform.tfstate"
    region         = "${var.staging_region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_state_lock_staging.name}"
    encrypt        = true
  }
  EOT
}

output "prod_backend_config" {
  description = "Backend configuration snippet for prod environment"
  value       = <<-EOT
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state_prod.id}"
    key            = "microservices/terraform.tfstate"
    region         = "${var.prod_region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_state_lock_prod.name}"
    encrypt        = true
  }
  EOT
}
