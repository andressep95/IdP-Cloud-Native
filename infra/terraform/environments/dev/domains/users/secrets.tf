# ============================================
# Users Domain - Secrets Manager
# ============================================

module "users_secrets" {
  source = "../../../../modules/secrets"

  secret_name = "${var.project_name}-${var.environment}-users-config"
  description = "Configuration secrets for users domain"

  secret_value = {
    # Database configuration
    dynamodb_table_name = module.user_table.table_name

    # Application configuration
    log_level = var.log_level

    # Add more secrets here as needed:
    # jwt_secret_key = "your-jwt-secret"
    # encryption_key = "your-encryption-key"
    # third_party_api_key = "your-api-key"
  }

  recovery_window_in_days = 0 # For dev, immediate deletion. For prod, use 7 or 30

  tags = merge(
    var.common_tags,
    {
      Domain    = local.domain_name
      SpecFile  = "spec/domains/users/infrastructure/security.yaml"
      SecretFor = "users-domain-config"
    }
  )
}
