# ============================================
# Users Domain - Secrets Manager
# ============================================

module "users_secrets" {
  source = "../../../../modules/secrets"

  secret_name = "${var.project_name}-${var.environment}-users-config"
  description = "Configuration secrets for users domain"

  secret_value = {
    # Source of Truth
    users_table_name = module.users_table.table_name

    # Materialized View
    user_directory_table_name = module.user_directory_table.table_name

    # Application configuration
    log_level = var.log_level
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
