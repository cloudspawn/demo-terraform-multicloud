# Data source for latest Ubuntu AMI (AWS)
data "aws_ami" "ubuntu" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# AWS Security Group
resource "aws_security_group" "instance" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  name        = "${var.project_name}-${var.environment}-instance-sg"
  description = "Security group for ${var.project_name} instances"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-instance-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# AWS EC2 Instance
resource "aws_instance" "main" {
  count                       = var.cloud_provider == "aws" ? var.instance_count : 0
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu[0].id
  instance_type               = var.instance_type != "" ? var.instance_type : "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.instance[0].id]
  key_name                    = var.key_name != "" ? var.key_name : null
  associate_public_ip_address = var.enable_public_ip

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# GCP Compute Instance
resource "google_compute_instance" "main" {
  count        = var.cloud_provider == "gcp" ? var.instance_count : 0
  name         = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
  machine_type = var.machine_type
  zone         = "${var.region}-a"
  project      = var.gcp_project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_id

    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        # Ephemeral public IP
      }
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = ["${var.project_name}-${var.environment}", "ssh-enabled"]

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_name
  }
}