# Network Module

Reusable Terraform module for creating VPC/VNet with public and private subnets on AWS and GCP.

## Features

- ✅ VPC creation (AWS) or VPC Network (GCP)
- ✅ Public and private subnets
- ✅ Internet Gateway (AWS)
- ✅ Route tables and associations (AWS)
- ✅ Firewall rules (GCP)
- ✅ Conditional resource creation based on cloud provider

## Usage

### AWS Example
```hcl
module "network" {
  source = "../../modules/network"

  cloud_provider       = "aws"
  project_name         = "my-project"
  environment          = "dev"
  region               = "eu-west-1"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
}
```

### GCP Example
```hcl
module "network" {
  source = "../../modules/network"

  cloud_provider       = "gcp"
  project_name         = "my-project"
  environment          = "dev"
  region               = "europe-west1"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24"]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cloud_provider | Cloud provider (aws or gcp) | string | - | yes |
| project_name | Project name for resource naming | string | "terraform-demo" | no |
| environment | Environment (dev, staging, prod) | string | "dev" | no |
| region | Cloud region | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | "10.0.0.0/16" | no |
| public_subnet_cidrs | CIDR blocks for public subnets | list(string) | ["10.0.1.0/24", "10.0.2.0/24"] | no |
| private_subnet_cidrs | CIDR blocks for private subnets | list(string) | ["10.0.10.0/24", "10.0.20.0/24"] | no |
| availability_zones | Availability zones (AWS only) | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC/Network ID |
| vpc_cidr | VPC CIDR block |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| internet_gateway_id | Internet Gateway ID (AWS only) |

## Resources Created

### AWS
- VPC
- Public subnets (configurable count)
- Private subnets (configurable count)
- Internet Gateway
- Route table for public subnets
- Route table associations

### GCP
- VPC Network (custom mode)
- Public subnet
- Private subnet
- Firewall rule for internal traffic
- Firewall rule for SSH access

## Notes

- GCP networks are global, subnets are regional
- AWS requires explicit route tables, GCP handles routing automatically
- GCP firewall rules are created at network level