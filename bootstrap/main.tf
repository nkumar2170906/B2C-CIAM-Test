
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Add this temporarily to your bootstrap/main.tf
import {
  to = aws_s3_bucket.tf_state
  id = "b2c-ciam-tfstate-nonprod" # Your exact existing S3 bucket name
}

/*
# =========================================================================
# 1. SECURE S3 BUCKET FOR REMOTE TERRAFORM STATE STORAGE
# =========================================================================

resource "aws_s3_bucket" "tf_state" {
  bucket        = var.s3_bucket_name
  force_destroy = false # Protects structural environment histories from accidental destruction

  tags = merge(var.global_tags, { Name = var.s3_bucket_name })
}

# Enforce Server-Side Encryption (SSE-S3) at rest for all state parameters
resource "aws_s3_bucket_server_side_encryption_configuration" "crypto" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly enable object versioning to recover from accidental overwrites
resource "aws_s3_bucket_versioning" "history" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public network exposure to align with enterprise cloud security compliance
resource "aws_s3_bucket_public_access_block" "security_wall" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================================
# 2. DYNAMODB TABLE FOR CONCURRENT TERRAFORM STATE LOCKING
# =========================================================================

resource "aws_dynamodb_table" "tf_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID" # Critical parameter required exactly by the S3 backend architecture

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.global_tags, { Name = var.dynamodb_table_name })
}
*/