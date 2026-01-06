# ============================================
# Backend Bootstrap - Terraform State Infrastructure
# ============================================
# Este Terraform crea los recursos necesarios para almacenar
# el state de Terraform de forma remota (S3 + DynamoDB)
#
# IMPORTANTE: Este Terraform usa backend LOCAL porque está
# creando la infraestructura donde se almacenará el state
# de otros environments.
# ============================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Backend local - bootstrap debe usar local backend
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Provider para staging
provider "aws" {
  alias   = "staging"
  region  = var.staging_region
  profile = var.staging_profile # Opcional: usar profile de AWS CLI

  default_tags {
    tags = {
      Project     = "Microservices"
      ManagedBy   = "Terraform"
      Purpose     = "Backend Infrastructure"
      Environment = "staging"
    }
  }
}

# Provider para prod
provider "aws" {
  alias   = "prod"
  region  = var.prod_region
  profile = var.prod_profile # Opcional: usar profile de AWS CLI

  default_tags {
    tags = {
      Project     = "Microservices"
      ManagedBy   = "Terraform"
      Purpose     = "Backend Infrastructure"
      Environment = "prod"
    }
  }
}

# ============================================
# S3 Bucket para Terraform State - STAGING
# ============================================

resource "aws_s3_bucket" "terraform_state_staging" {
  provider = aws.staging

  bucket = var.staging_state_bucket_name

  tags = {
    Name        = var.staging_state_bucket_name
    Environment = "staging"
  }
}

# Versionado del bucket staging
resource "aws_s3_bucket_versioning" "terraform_state_staging" {
  provider = aws.staging

  bucket = aws_s3_bucket.terraform_state_staging.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptación del bucket staging
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_staging" {
  provider = aws.staging

  bucket = aws_s3_bucket.terraform_state_staging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acceso público staging
resource "aws_s3_bucket_public_access_block" "terraform_state_staging" {
  provider = aws.staging

  bucket = aws_s3_bucket.terraform_state_staging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================
# DynamoDB Table para State Locking - STAGING
# ============================================

resource "aws_dynamodb_table" "terraform_state_lock_staging" {
  provider = aws.staging

  name         = var.staging_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.staging_lock_table_name
    Environment = "staging"
  }
}

# ================================================================================================================================================================================
# ================================================================================================================================================================================


# ============================================
# S3 Bucket para Terraform State - PROD
# ============================================

resource "aws_s3_bucket" "terraform_state_prod" {
  provider = aws.prod

  bucket = var.prod_state_bucket_name

  tags = {
    Name        = var.prod_state_bucket_name
    Environment = "prod"
  }
}

# Versionado del bucket prod
resource "aws_s3_bucket_versioning" "terraform_state_prod" {
  provider = aws.prod

  bucket = aws_s3_bucket.terraform_state_prod.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptación del bucket prod
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_prod" {
  provider = aws.prod

  bucket = aws_s3_bucket.terraform_state_prod.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquear acceso público prod
resource "aws_s3_bucket_public_access_block" "terraform_state_prod" {
  provider = aws.prod

  bucket = aws_s3_bucket.terraform_state_prod.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================
# DynamoDB Table para State Locking - PROD
# ============================================

resource "aws_dynamodb_table" "terraform_state_lock_prod" {
  provider = aws.prod

  name         = var.prod_lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.prod_lock_table_name
    Environment = "prod"
  }
}
