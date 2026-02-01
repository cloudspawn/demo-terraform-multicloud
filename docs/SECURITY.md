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

**Option 1: AWS CLI (Recommended)**
```bash
aws configure
# This stores credentials in ~/.aws/credentials
# Terraform automatically detects them
```

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="eu-west-1"
```

**Option 3: IAM Roles (Production)**
- Use EC2 instance profiles
- Use ECS task roles
- Use Lambda execution roles

#### GCP Credentials

**Option 1: Service Account Key + Env Var (Recommended for local)**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/terraform-sa-key.json"
# Terraform automatically detects this
```

**Option 2: gcloud CLI**
```bash
gcloud auth application-default login
# Creates credentials in ~/.config/gcloud/
```

**Option 3: Workload Identity (Production on GKE)**
- Use Workload Identity for pods
- No need for service account keys

## 🛡️ Terraform State Security

### State File Protection

Terraform state files (`*.tfstate`) contain sensitive data:
- Resource IDs
- IP addresses
- Sometimes passwords or keys

**Never commit state files to Git!**

### Remote Backend (Recommended for teams)

**AWS S3 Backend:**
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

**GCP Cloud Storage Backend:**
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}
```

## 🔐 Secrets in Variables

### ❌ WRONG - Never do this
```hcl
variable "database_password" {
  default = "mysecretpassword123"  # ❌ NEVER!
}
```

### ✅ CORRECT - Use external sources
```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  # No default value!
}
```

**Provide via:**
- Environment variable: `export TF_VAR_database_password="..."`
- Prompt during apply: Terraform will ask
- Secrets manager: AWS Secrets Manager, GCP Secret Manager

## 📋 Pre-Commit Checklist

Before committing code, verify:

- [ ] No `*.tfvars` files (except `*.tfvars.example`)
- [ ] No `*.json` credential files
- [ ] No hardcoded passwords or API keys
- [ ] `.gitignore` is up to date
- [ ] State files are not tracked
- [ ] Environment variables documented in `.env.example`

## 🚨 If You Accidentally Commit Secrets

1. **Immediately rotate the credentials** (invalidate old ones)
2. Remove from Git history:
```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch path/to/secret/file" \
     --prune-empty --tag-name-filter cat -- --all
```
3. Force push (if you're the only one working on the branch)
4. Notify your team

## 📚 Additional Resources

- [Terraform Security Best Practices](https://www.terraform.io/docs/language/values/variables.html#sensitive-values)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GCP Security Best Practices](https://cloud.google.com/security/best-practices)