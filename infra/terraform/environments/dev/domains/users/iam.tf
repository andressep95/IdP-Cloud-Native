
# ============================================
# Users Read IAM Role
# From: spec/domains/users/infrastructure/security.yaml
# ============================================
module "users_read_iam" {
  source = "../../../../modules/iam"

  domain_name = local.domain_name
  environment = var.environment

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  custom_policies = {
    dynamodb-read = {
      description = "Read-only access to users table"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:Query"
          ]
          Resource = [
            module.user_table.table_arn,
            "${module.user_table.table_arn}/index/*"
          ]
        }]
      })
    }
  }
}

# ============================================
# Users Write IAM Role
# From: spec/domains/users/infrastructure/security.yaml
# ============================================
module "users_write_iam" {
  source = "../../../../modules/iam"

  domain_name = local.domain_name
  environment = var.environment

  # AWS Managed Policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]

  # Custom Policies
  # Permissions from: spec/domains/users/infrastructure/compute.yaml
  custom_policies = {

    dynamodb-access = {
      description = "DynamoDB access for Users write operations"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "UsersWriteTableAccess"
            Effect = "Allow"
            Action = [
              "dynamodb:GetItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem"
            ]
            Resource = [
              module.user_table.table_arn,
            ]
          }
        ]
      })
    }

    # Secrets Manager Access
    secrets-access = {
      description = "Secrets Manager access for users domain Lambda functions"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "ReadUsersSecrets"
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret"
            ]
            Resource = module.users_secrets.secret_arn
          }
        ]
      })
    }
  }

  tags = merge(
    var.common_tags,
    {
      Domain   = local.domain_name
      SpecFile = "spec/domains/users/infrastructure/security.yaml"
    }
  )
}
