# ============================================
# Users Domain - IAM Role
# From: spec/domains/users/infrastructure/security.yaml
# ============================================

module "users_iam" {
  source = "../../../../modules/iam"

  domain_name = local.domain_name
  environment = var.environment

  # AWS Managed Policies
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]

  # Custom DynamoDB Policy
  # Permissions from: spec/domains/users/infrastructure/compute.yaml
  # - users-create needs: PutItem, GetItem
  # - users-get needs: GetItem, Query
  # - users-list needs: Scan, Query
  # - users-update needs: GetItem, UpdateItem
  # - users-delete needs: GetItem, UpdateItem (soft delete)
  custom_policies = {
    dynamodb-access = {
      description = "DynamoDB access for users domain Lambda functions"
      policy_document = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "UsersTableAccess"
            Effect = "Allow"
            Action = [
              "dynamodb:GetItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem",
              "dynamodb:Query",
              "dynamodb:Scan"
            ]
            Resource = [
              module.user_table.table_arn,
              "${module.user_table.table_arn}/index/*"
            ]
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
