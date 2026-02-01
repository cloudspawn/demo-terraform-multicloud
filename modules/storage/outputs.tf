output "bucket_name" {
  description = "Bucket name"
  value       = local.bucket_name
}

output "bucket_id" {
  description = "Bucket ID"
  value       = var.cloud_provider == "aws" ? (length(aws_s3_bucket.main) > 0 ? aws_s3_bucket.main[0].id : null) : (length(google_storage_bucket.main) > 0 ? google_storage_bucket.main[0].id : null)
}

output "bucket_arn" {
  description = "Bucket ARN (AWS only)"
  value       = var.cloud_provider == "aws" ? (length(aws_s3_bucket.main) > 0 ? aws_s3_bucket.main[0].arn : null) : null
}

output "bucket_url" {
  description = "Bucket URL"
  value       = var.cloud_provider == "aws" ? (length(aws_s3_bucket.main) > 0 ? aws_s3_bucket.main[0].bucket_regional_domain_name : null) : (length(google_storage_bucket.main) > 0 ? google_storage_bucket.main[0].url : null)
}