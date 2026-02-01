# Network Module
module "network" {
  source = "../../modules/network"

  cloud_provider       = "aws"
  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Compute Module
module "compute" {
  count  = var.enable_compute ? 1 : 0
  source = "../../modules/compute"

  cloud_provider   = "aws"
  project_name     = var.project_name
  environment      = var.environment
  region           = var.region
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.public_subnet_ids[0]
  instance_type    = var.instance_type
  instance_count   = var.instance_count
  enable_public_ip = true
}

# Storage Module
module "storage" {
  count  = var.enable_storage ? 1 : 0
  source = "../../modules/storage"

  cloud_provider     = "aws"
  project_name       = var.project_name
  environment        = var.environment
  region             = var.region
  versioning_enabled = true
  encryption_enabled = true
  force_destroy      = true # Only for dev/demo
}