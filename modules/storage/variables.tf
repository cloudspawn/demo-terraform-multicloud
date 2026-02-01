variable "cloud_provider" {
  description = "Cloud provider (aws or gcp) - REQUIRED"
  type        = string
  validation {
    condition     = contains(["aws", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be 'aws' or 'gcp'."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-demo"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Cloud region"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "Bucket name (must be globally unique)"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = true
}

variable "encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}