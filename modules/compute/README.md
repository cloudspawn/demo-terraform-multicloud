# Compute Module

Reusable Terraform module for creating virtual machine instances on AWS (EC2) and GCP (Compute Engine).

## Features

- ✅ EC2 instances with Security Groups (AWS)
- ✅ Compute Engine instances with firewall tags (GCP)
- ✅ Automatic Ubuntu 22.04 LTS AMI selection (AWS)
- ✅ Configurable instance types and machine types
- ✅ Public/Private IP support
- ✅ SSH key configuration (AWS)
- ✅ Conditional resource creation based on cloud provider

## Usage

### AWS Example
```hcl
module "compute" {
  source = "../../modules/compute"

  cloud_provider  = "aws"
  project_name    = "my-project"
  environment     = "dev"
  region          = "eu-west-1"
  vpc_id          = module.network.vpc_id
  subnet_id       = module.network.public_subnet_ids[0]
  instance_type   = "t2.micro"
  instance_count  = 2
  key_name        = "my-ssh-key"
  enable_public_ip = true
}
```

### GCP Example
```hcl
module "compute" {
  source = "../../modules/compute"

  cloud_provider  = "gcp"
  project_name    = "my-project"
  environment     = "dev"
  region          = "europe-west1"
  gcp_project_id  = "my-gcp-project-123"
  vpc_id          = module.network.vpc_id
  subnet_id       = module.network.public_subnet_ids[0]
  machine_type    = "e2-micro"
  instance_count  = 1
  enable_public_ip = true
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cloud_provider | Cloud provider (aws or gcp) | string | - | yes |
| project_name | Project name for resource naming | string | "terraform-demo" | no |
| environment | Environment (dev, staging, prod) | string | "dev" | no |
| region | Cloud region | string | - | yes |
| vpc_id | VPC ID (AWS) or Network ID (GCP) | string | - | yes |
| subnet_id | Subnet ID for the instance | string | - | yes |
| instance_type | Instance type for AWS (e.g., t2.micro) | string | "" | no |
| machine_type | Machine type for GCP (e.g., e2-micro) | string | "e2-micro" | no |
| ami_id | AMI ID for AWS (uses latest Ubuntu if empty) | string | "" | no |
| gcp_project_id | GCP Project ID | string | "" | no |
| instance_count | Number of instances to create | number | 1 | no |
| key_name | SSH key name (AWS only) | string | "" | no |
| enable_public_ip | Enable public IP assignment | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | List of instance IDs |
| public_ips | List of public IP addresses |
| private_ips | List of private IP addresses |
| security_group_id | Security Group ID (AWS only) |

## Resources Created

### AWS
- EC2 instances (configurable count)
- Security Group with rules:
  - SSH (port 22)
  - HTTP (port 80)
  - HTTPS (port 443)
  - All outbound traffic
- EBS root volume (8GB gp3)

### GCP
- Compute Engine instances (configurable count)
- Boot disk (10GB, Ubuntu 22.04 LTS)
- Network interface with optional public IP
- Firewall tags for SSH access
- OS Login enabled

## Notes

- AWS instances use the latest Ubuntu 22.04 LTS AMI by default
- GCP instances use `ubuntu-os-cloud/ubuntu-2204-lts`
- Security Group (AWS) allows SSH/HTTP/HTTPS from anywhere (0.0.0.0/0)
- For production, restrict SSH to specific IP ranges
- GCP instances require firewall rules in the Network module