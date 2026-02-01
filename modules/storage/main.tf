# Generate bucket name if not provided
locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
}

# Random suffix for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# AWS S3 Bucket
resource "aws_s3_bucket" "main" {
  count         = var.cloud_provider == "aws" ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# AWS S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# AWS S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.cloud_provider == "aws" && var.encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# AWS S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.main[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# GCP Cloud Storage Bucket
resource "google_storage_bucket" "main" {
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = local.bucket_name
  location      = upper(var.region)
  project       = var.gcp_project_id
  force_destroy = var.force_destroy

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "encryption" {
    for_each = var.encryption_enabled ? [1] : []
    content {
      default_kms_key_name = null
    }
  }

  uniform_bucket_level_access = true

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}