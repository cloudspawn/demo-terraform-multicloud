# Storage Module

Reusable Terraform module for creating object storage buckets on AWS (S3) and GCP (Cloud Storage).

## Features

- ✅ S3 buckets with encryption and versioning (AWS)
- ✅ Cloud Storage buckets with encryption and versioning (GCP)
- ✅ Automatic unique bucket naming with random suffix
- ✅ Public access blocking (AWS)
- ✅ Uniform bucket-level access (GCP)
- ✅ Conditional resource creation based on cloud provider

## Usage

### AWS Example
```hcl
module "storage" {
  source = "../../modules/storage"

  cloud_provider      = "aws"
  project_name        = "my-project"
  environment         = "dev"
  region              = "eu-west-1"
  bucket_name         = "my-unique-bucket-name"  # Optional
  versioning_enabled  = true
  encryption_enabled  = true
  force_destroy       = false
}
```

### GCP Example
```hcl
module "storage" {
  source = "../../modules/storage"

  cloud_provider      = "gcp"
  project_name        = "my-project"
  environment         = "dev"
  region              = "europe-west1"
  gcp_project_id      = "my-gcp-project-123"
  bucket_name         = "my-unique-bucket-name"  # Optional
  versioning_enabled  = true
  encryption_enabled  = true
  force_destroy       = false
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cloud_provider | Cloud provider (aws or gcp) | string | - | yes |
| project_name | Project name for resource naming | string | "terraform-demo" | no |
| environment | Environment (dev, staging, prod) | string | "dev" | no |
| region | Cloud region | string | - | yes |
| gcp_project_id | GCP Project ID | string | "" | no |
| bucket_name | Bucket name (auto-generated if empty) | string | "" | no |
| force_destroy | Allow bucket deletion even if not empty | bool | false | no |
| versioning_enabled | Enable object versioning | bool | true | no |
| encryption_enabled | Enable server-side encryption | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | Bucket name |
| bucket_id | Bucket ID |
| bucket_arn | Bucket ARN (AWS only) |
| bucket_url | Bucket URL |

## Resources Created

### AWS
- S3 Bucket
- Bucket versioning configuration
- Server-side encryption (AES256)
- Public access block (all public access denied)

### GCP
- Cloud Storage Bucket
- Versioning enabled
- Uniform bucket-level access
- Regional or multi-regional storage

## Notes

- Bucket names must be globally unique across all AWS/GCP accounts
- If no `bucket_name` provided, auto-generated: `{project}-{env}-{random}`
- AWS buckets block all public access by default (security best practice)
- GCP buckets use uniform bucket-level access (recommended)
- Set `force_destroy = true` only for dev/test environments
- Encryption is enabled by default (AWS: AES256, GCP: Google-managed keys)
