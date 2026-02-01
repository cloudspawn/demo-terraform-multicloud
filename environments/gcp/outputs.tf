# Network Outputs
output "vpc_id" {
  description = "VPC Network ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

# Compute Outputs
output "instance_ids" {
  description = "Instance IDs"
  value       = var.enable_compute ? module.compute[0].instance_ids : []
}

output "instance_public_ips" {
  description = "Instance public IPs"
  value       = var.enable_compute ? module.compute[0].public_ips : []
}

output "instance_private_ips" {
  description = "Instance private IPs"
  value       = var.enable_compute ? module.compute[0].private_ips : []
}

# Storage Outputs
output "bucket_name" {
  description = "Cloud Storage bucket name"
  value       = var.enable_storage ? module.storage[0].bucket_name : null
}

output "bucket_url" {
  description = "Cloud Storage bucket URL"
  value       = var.enable_storage ? module.storage[0].bucket_url : null
}