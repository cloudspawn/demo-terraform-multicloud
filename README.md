# Multi-Cloud Infrastructure with Terraform

Infrastructure as Code demonstration deploying identical architectures on AWS and GCP using reusable Terraform modules.

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)

## Status
🚧 In Development - Network module complete

## Stack

- **Terraform** - Infrastructure as Code
- **AWS** - Cloud provider 1 (eu-west-1)
- **GCP** - Cloud provider 2 (europe-west1)
- **GitHub Actions** - CI/CD for terraform validation

## Architecture

### Modules (Reusable)
- **Network** ✅ - VPC/VNet with public/private subnets
- **Compute** 🚧 - Virtual machines (EC2/Compute Engine)
- **Storage** 🚧 - Object storage (S3/Cloud Storage)

### Environments
- **AWS** - Deployed in eu-west-1
- **GCP** - Deployed in europe-west1

## 🔒 Security

This project follows infrastructure security best practices:

- ✅ **No credentials in code** - All sensitive data excluded via `.gitignore`
- ✅ **Environment-based config** - Credentials via AWS CLI and environment variables
- ✅ **Separate tfvars** - Real values in gitignored files, examples in repo
- ✅ **State file protection** - State files never committed

**See [docs/SECURITY.md](docs/SECURITY.md) for detailed security guidelines.**

## Prerequisites

### Tools
```bash
# Terraform (>= 1.0)
terraform --version

# AWS CLI
aws --version

# GCP CLI (optional)
gcloud --version
```

### Credentials Setup

**1. Configure AWS:**
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: eu-west-1
```

**2. Configure GCP:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/terraform-sa-key.json"
```

**3. Copy example tfvars:**
```bash
# AWS
cp environments/aws/terraform.tfvars.example environments/aws/terraform.tfvars
# Edit with your values

# GCP
cp environments/gcp/terraform.tfvars.example environments/gcp/terraform.tfvars
# Edit with your values
```

⚠️ **Never commit `terraform.tfvars` files - they are gitignored!**

## Usage

### Deploy on AWS
```bash
cd environments/aws
terraform init
terraform plan
terraform apply
```

### Deploy on GCP
```bash
cd environments/gcp
terraform init
terraform plan
terraform apply
```

### Destroy Infrastructure

⚠️ **Important:** Always destroy resources after demo to avoid charges!
```bash
# AWS
cd environments/aws
terraform destroy

# GCP
cd environments/gcp
terraform destroy
```

## Project Structure
```
demo-terraform-multicloud/
├── modules/              # Reusable Terraform modules
│   ├── network/         # VPC/networking (AWS + GCP)
│   ├── compute/         # VM instances
│   └── storage/         # Object storage (S3/GCS)
├── environments/
│   ├── aws/             # AWS infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   └── gcp/             # GCP infrastructure
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
└── docs/
    └── SECURITY.md      # Security best practices
```

## Cost Estimation

**AWS:** ~$5-10/month (Free Tier eligible)
**GCP:** ~$5-10/month ($300 free credits for 90 days)

⚠️ **Remember to `terraform destroy` after demo!**

## What I Learned

### Terraform Best Practices
- Modular architecture for code reusability
- Conditional resource creation based on cloud provider
- Variable validation and type constraints
- Output management across modules

### Multi-Cloud Patterns
- Abstracting cloud provider differences
- Consistent naming conventions across clouds
- Network architecture variations (AWS vs GCP)
- Provider-specific features and limitations

### Infrastructure Security
- Credential management (AWS CLI, gcloud, env vars)
- Secret separation (`.tfvars` vs `.tfvars.example`)
- State file protection and remote backends
- Secrets management solutions (AWS/GCP/Vault)

### DevOps Skills
- Infrastructure as Code workflows
- Terraform state management
- CI/CD for infrastructure validation
- Cost optimization strategies

## Related Projects

This is Demo #4 of my portfolio:

1. **CI/CD Pipeline** - FastAPI + Docker + GitHub Actions
2. **Airflow Data Pipeline** - Orchestration + DuckDB
3. **AI Multi-Agent System** - LangGraph + Ollama
4. **Terraform Multi-Cloud** ← You are here

## License

MIT