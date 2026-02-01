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

variable "vpc_id" {
  description = "VPC ID (AWS) or Network ID (GCP)"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type (AWS: t2.micro, GCP: e2-micro)"
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "Machine type for GCP (e2-micro, e2-small, etc.)"
  type        = string
  default     = "e2-micro"
}

variable "ami_id" {
  description = "AMI ID for AWS EC2 (Ubuntu 22.04 recommended)"
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "SSH key name (AWS only)"
  type        = string
  default     = ""
}

variable "enable_public_ip" {
  description = "Enable public IP assignment"
  type        = bool
  default     = true
}