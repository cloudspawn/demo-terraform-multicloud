cat > docs/SECURITY.md << 'EOF'
# Security Best Practices

## 🔒 Credentials Management

### ⚠️ NEVER Commit These Files

The following files contain sensitive data and are protected by `.gitignore`:

- `*.tfvars` (except `*.tfvars.example`)
- `*.json` (service account keys)
- `*.pem`, `*.key` (SSH keys)
- `.env` (environment variables)

### ✅ Recommended Approach

#### AWS Credentials

**Local Development:**
```bash
aws configure
# Stores credentials in ~/.aws/credentials
# Terraform automatically detects them
```

**Production:** Use IAM roles (EC2 instance profiles, ECS task roles)

#### GCP Credentials

**Local Development:**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/terraform-sa-key.json"
# Terraform automatically detects this
```

**Production:** Use Workload Identity (GKE) or service account impersonation

## 🔐 Secrets Management (Production)

For production environments, **never store secrets in code or tfvars files**. Use dedicated secrets managers:

### Cloud-Native Solutions

| Provider | Solution | Use Case |
|----------|----------|----------|
| **AWS** | Secrets Manager / Parameter Store | AWS resources, auto-rotation |
| **GCP** | Secret Manager | GCP resources, versioning |
| **Azure** | Key Vault | Azure resources |

**Example (AWS Secrets Manager):**
```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### Multi-Cloud / Enterprise

**HashiCorp Vault** - For advanced multi-cloud scenarios:
- Dynamic secrets with auto-rotation
- Encryption as a service
- Detailed audit logs
- Multi-cloud support

## 🛡️ Terraform State Security

**State files contain sensitive data!**

### Remote Backend (Recommended)

**AWS S3:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**GCP Cloud Storage:**
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}
```

**Terraform Cloud:** Managed state with versioning, locking, and team collaboration

## 📋 Pre-Commit Checklist

Before committing code:

- [ ] No `*.tfvars` files (except `*.tfvars.example`)
- [ ] No credential files (`*.json`, `*.pem`, `*.key`)
- [ ] No hardcoded passwords or API keys
- [ ] State files not tracked
- [ ] Sensitive variables marked with `sensitive = true`

## 🚨 If You Accidentally Commit Secrets

1. **Immediately rotate the credentials** (invalidate old ones)
2. Remove from Git history (use `git filter-repo` or `BFG Repo-Cleaner`)
3. Consider the secret compromised

## 📚 Additional Resources

- [Terraform Security Best Practices](https://www.terraform.io/docs/language/values/variables.html#sensitive-values)
- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)
EOF