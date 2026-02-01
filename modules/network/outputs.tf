cat > modules/network/outputs.tf << 'EOF'
# AWS Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = var.cloud_provider == "aws" ? aws_vpc.main[0].id : (var.cloud_provider == "gcp" ? google_compute_network.main[0].id : null)
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = var.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = var.cloud_provider == "aws" ? aws_subnet.public[*].id : (var.cloud_provider == "gcp" ? [google_compute_subnetwork.public[0].id] : [])
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = var.cloud_provider == "aws" ? aws_subnet.private[*].id : (var.cloud_provider == "gcp" ? [google_compute_subnetwork.private[0].id] : [])
}

output "internet_gateway_id" {
  description = "Internet Gateway ID (AWS only)"
  value       = var.cloud_provider == "aws" ? aws_internet_gateway.main[0].id : null
}
EOF