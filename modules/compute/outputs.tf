output "instance_ids" {
  description = "Instance IDs"
  value       = var.cloud_provider == "aws" ? aws_instance.main[*].id : google_compute_instance.main[*].id
}

output "public_ips" {
  description = "Public IP addresses"
  value       = var.cloud_provider == "aws" ? aws_instance.main[*].public_ip : (var.enable_public_ip ? google_compute_instance.main[*].network_interface[0].access_config[0].nat_ip : [])
}

output "private_ips" {
  description = "Private IP addresses"
  value       = var.cloud_provider == "aws" ? aws_instance.main[*].private_ip : google_compute_instance.main[*].network_interface[0].network_ip
}

output "security_group_id" {
  description = "Security Group ID (AWS only)"
  value       = var.cloud_provider == "aws" ? (length(aws_security_group.instance) > 0 ? aws_security_group.instance[0].id : null) : null
}