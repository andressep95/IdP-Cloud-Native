# ============================================
# Users Domain - Local Variables
# From: spec/domains/users/infrastructure/
# ============================================

locals {
  domain_name = "users"

  # Lambda configurations
  # From: spec/domains/users/infrastructure/compute.yaml
  lambda_configs = {
    users-create = {
      description                    = "Create a new user"
      use_case                       = "UC-USERS-001"
      api_operation                  = "createUser"
      memory_size                    = 512
      timeout                        = 30
      reserved_concurrent_executions = 100
      log_retention_days             = 30
      xray_enabled                   = true
      error_threshold                = 10
      error_period                   = 300
      error_evaluation_periods       = 2
      duration_threshold             = 10000
      duration_period                = 60
      duration_evaluation_periods    = 3
    }

    # FUTURE: Add more Lambda configs as you implement them
    # users-get = { ... }
    # users-list = { ... }
    # users-update = { ... }
    # users-delete = { ... }
  }
}
