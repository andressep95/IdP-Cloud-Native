# ============================================
# Users Domain - DynamoDB Table
# From: spec/domains/users/infrastructure/storage.yaml
# ============================================

module "user_table" {
  source = "../../../../modules/dynamodb"

  # Table naming: {project}-{environment}-{domain}
  table_name  = "${var.project_name}-${var.environment}-users"
  environment = var.environment

  # Billing and protection
  billing_mode                   = "PAY_PER_REQUEST"
  deletion_protection_enabled    = var.enable_deletion_protection
  point_in_time_recovery_enabled = true

  # Encryption
  server_side_encryption_enabled = true
  kms_key_arn                    = null # AWS managed key

  # TTL
  ttl_enabled        = true
  ttl_attribute_name = "ttl"

  # Streams (disabled per spec)
  stream_enabled   = false
  stream_view_type = null

  # Primary key
  hash_key  = "userId"
  range_key = null

  # Attributes (only indexed ones)
  attributes = [
    {
      name = "userId"
      type = "S" # UUID v4
    },
    {
      name = "email"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    },
    {
      name = "entityType"
      type = "S"
    },
    {
      name = "createdAt"
      type = "S"
    }
  ]

  # Global Secondary Indexes
  global_secondary_indexes = [
    # GSI-1: email-index
    {
      name            = "email-index"
      hash_key        = "email"
      range_key       = null
      projection_type = "ALL"
    },
    # GSI-2: status-created-index
    {
      name            = "status-created-index"
      hash_key        = "status"
      range_key       = "createdAt"
      projection_type = "ALL"
    },
    # GSI-3: all-users-index
    {
      name            = "all-users-index"
      hash_key        = "entityType"
      range_key       = "createdAt"
      projection_type = "ALL"
    }
  ]

  local_secondary_indexes = []

  tags = merge(
    var.common_tags,
    {
      Domain             = local.domain_name
      DataClassification = "PII"
      Compliance         = "GDPR,SOC2"
      RetentionPeriod    = "7years"
      CostCenter         = "identity-platform"
      Owner              = "idp-team@company.com"
      SpecFile           = "spec/domains/users/infrastructure/storage.yaml"
    }
  )
}
