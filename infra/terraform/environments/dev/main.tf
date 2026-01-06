# ============================================
# Users Domain - DynamoDB Table
# Implements: spec/domains/users/infrastructure/storage.yaml
# ============================================

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# ============================================
# DynamoDB Table - Users
# ============================================

module "user_table" {
  source = "../../modules/dynamodb"


  # ============================================
  # BASIC CONFIGURATION
  # From storage.yaml
  # ============================================

  # Table naming: {project}-{environment}-{domain}
  table_name  = "${var.project_name}-${var.environment}-users"
  environment = var.environment


  # ============================================
  # CONFIGURATION (from storage.yaml)
  # ============================================

  # billing_mode: PAY_PER_REQUEST
  billing_mode = "PAY_PER_REQUEST"

  # deletion_protection: true
  deletion_protection_enabled = var.environment == "prod" ? true : false

  # point_in_time_recovery: true
  point_in_time_recovery_enabled = true

  # encryption.at_rest: AWS_MANAGED_KMS
  server_side_encryption_enabled = true
  kms_key_arn                    = null # AWS managed key

  # ttl.enabled: true
  ttl_enabled        = true
  ttl_attribute_name = "ttl"

  # streams.enabled: false
  stream_enabled   = false
  stream_view_type = null


  # ============================================
  # PRIMARY KEY (from storage.yaml)
  # ============================================

  # primary_key.partition_key: userId
  hash_key = "userId"

  # primary_key.sort_key: null
  range_key = null


  # ============================================
  # ATTRIBUTES (from storage.yaml)
  # ONLY indexed attributes (used in keys/GSIs)
  # ============================================

  attributes = [
    # Primary key
    {
      name = "userId"
      type = "S" # UUID v4
    },

    # GSI-1: email-index (partition key)
    {
      name = "email"
      type = "S"
    },

    # GSI-2: status-created-index (partition key)
    {
      name = "status"
      type = "S"
    },

    # GSI-3: all-users-index (partition key)
    {
      name = "entityType"
      type = "S"
    },

    # GSI-2 & GSI-3: sort key
    {
      name = "createdAt"
      type = "S"
    }
  ]


  # ============================================
  # NOTE: Non-indexed attributes are NOT defined here
  # ============================================
  # These are managed by the application:
  # - passwordHash (S)
  # - firstName (S)
  # - lastName (S)
  # - phoneNumber (S)
  # - metadata (M)
  # - updatedAt (S)
  # - lastLoginAt (S)
  # - ttl (N) - used for TTL but not indexed


  # ============================================
  # GLOBAL SECONDARY INDEXES (from storage.yaml)
  # ============================================

  global_secondary_indexes = [
    # GSI-1: email-index
    # Purpose: Fast lookup by email (login, duplicate check)
    {
      name            = "email-index"
      hash_key        = "email"
      range_key       = null
      projection_type = "ALL"
    },

    # GSI-2: status-created-index
    # Purpose: Filter users by status and sort by creation date
    {
      name            = "status-created-index"
      hash_key        = "status"
      range_key       = "createdAt"
      projection_type = "ALL"
    },

    # GSI-3: all-users-index
    # Purpose: List all users with pagination
    # Note: Single partition design, suitable for <100K users
    {
      name            = "all-users-index"
      hash_key        = "entityType"
      range_key       = "createdAt"
      projection_type = "ALL"
    }
  ]


  # ============================================
  # LOCAL SECONDARY INDEXES (from storage.yaml)
  # ============================================

  # local_secondary_indexes: []
  local_secondary_indexes = []

  # ============================================
  # TAGS (from storage.yaml)
  # ============================================

  tags = merge(
    var.common_tags,
    {
      # From storage.yaml tags section
      DataClassification = "PII"
      Compliance         = "GDPR,SOC2"
      RetentionPeriod    = "7years"
      CostCenter         = "identity-platform"
      Owner              = "idp-team@company.com"
      Domain             = "users"

      # Additional context
      SpecFile = "spec/domains/users/infrastructure/storage.yaml"
    }
  )
}

