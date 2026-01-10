# ============================================
# Users Domain - DynamoDB Table
# From: spec/domains/users/infrastructure/storage.yaml
# ============================================
module "users_table" {
  source = "../../../../modules/dynamodb"

  table_name  = "${var.project_name}-${var.environment}-users"
  environment = var.environment

  billing_mode                   = "PAY_PER_REQUEST"
  deletion_protection_enabled    = var.enable_deletion_protection
  point_in_time_recovery_enabled = true

  server_side_encryption_enabled = true
  kms_key_arn                    = null

  ttl_enabled        = true
  ttl_attribute_name = "ttl"

  stream_enabled   = false
  stream_view_type = null

  hash_key  = "userId"
  range_key = null

  attributes = [
    { name = "userId", type = "S" },
    { name = "email", type = "S" },
    { name = "status", type = "S" },
    { name = "createdAt", type = "S" }
  ]

  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      range_key       = null
      projection_type = "ALL"
    },
    {
      name            = "status-created-index"
      hash_key        = "status"
      range_key       = "createdAt"
      projection_type = "INCLUDE"
      non_key_attributes = [
        "userId",
        "email",
        "createdAt"
      ]
    }
  ]

  tags = merge(var.common_tags, {
    Domain             = "users"
    DataClassification = "PII"
    Compliance         = "GDPR,SOC2"
    ManagedBy          = "Terraform"
  })
}


# ============================================
# User Directory Table
# From: spec/domains/users/infrastructure/storage.yaml
# ============================================
module "user_directory_table" {
  source = "../../../../modules/dynamodb"

  table_name  = "${var.project_name}-${var.environment}-user-directory"
  environment = var.environment

  billing_mode                   = "PAY_PER_REQUEST"
  deletion_protection_enabled    = false
  point_in_time_recovery_enabled = false

  server_side_encryption_enabled = true
  kms_key_arn                    = null

  ttl_enabled = false

  stream_enabled   = false
  stream_view_type = null

  hash_key  = "directoryShard"
  range_key = "createdAtUserId"

  attributes = [
    { name = "directoryShard", type = "S" },
    { name = "createdAtUserId", type = "S" },
    { name = "userId", type = "S" },
    { name = "email", type = "S" },
    { name = "status", type = "S" },
    { name = "createdAt", type = "S" }
  ]

  tags = merge(var.common_tags, {
    Domain             = "users"
    DataClassification = "Internal"
    ManagedBy          = "Terraform"
  })
}
