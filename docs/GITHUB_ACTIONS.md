# GitHub Actions CI/CD

This project uses GitHub Actions for automated Terraform validation and testing.

## Workflows

### Terraform CI (`terraform.yml`)

**Triggers:**
- Pull requests to `main` branch
- Pushes to `dev` branch
- Manual dispatch (via GitHub UI)

**Jobs:**

1. **Terraform Validation** (Matrix: AWS + GCP)
   - Format check (`terraform fmt -check`)
   - Initialization (`terraform init -backend=false`)
   - Validation (`terraform validate`)

2. **Terraform Lint** (TFLint)
   - Checks best practices
   - AWS and GCP rulesets enabled

3. **Terraform Security** (tfsec)
   - Scans for security vulnerabilities
   - Soft-fail mode (warnings don't block)

4. **CI Summary**
   - Aggregates all results

## Manual Workflow Dispatch

You can manually trigger the workflow from GitHub Actions tab:

1. Go to **Actions** tab on GitHub
2. Select **Terraform CI** workflow
3. Click **Run workflow** button
4. Choose options:
   - **Environment**: `aws` or `gcp`
   - **Action**: `validate` or `plan`

### Action Options

#### Validate (Default)
- ✅ Runs format check, init, and validation
- ✅ No credentials required
- ✅ Always succeeds if code is valid

#### Plan (Demo only)
- ⚠️ **Will fail without credentials** (expected behavior)
- Demonstrates what a full CI/CD pipeline would include
- Shows error: "No valid credential sources found"

**Why no credentials?**
- This is a demonstration project
- Credentials in CI/CD require GitHub Secrets setup
- Prevents accidental cloud resource creation/costs
- Real deployments done manually from local machine

## Setting Up Full CI/CD (Optional)

If you want `terraform plan` to work in GitHub Actions:

### Option 1: GitHub Secrets (AWS)

**Add secrets in Settings → Secrets and variables → Actions:**
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

**Update workflow to use secrets:**
```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}
```

### Option 2: GitHub Secrets (GCP)

**Add secrets:**
```
GCP_PROJECT_ID
GCP_SA_KEY  # Base64-encoded service account JSON
```

**Update workflow:**
```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v2
  with:
    credentials_json: ${{ secrets.GCP_SA_KEY }}
```

### Option 3: Terraform Cloud (Recommended for production)

1. Create account on [app.terraform.io](https://app.terraform.io)
2. Create workspace linked to GitHub repo
3. Add cloud credentials to Terraform Cloud
4. Runs happen in Terraform Cloud (not GitHub Actions)

**Benefits:**
- ✅ Centralized state management
- ✅ UI for plan review
- ✅ Automatic plan on PR
- ✅ Secure credential storage

### Option 4: OIDC (No long-lived credentials)

**AWS:**
```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT:role/GitHubActionsRole
    aws-region: eu-west-1
```

**GCP:**
```yaml
- name: Authenticate to GCP
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/...'
    service_account: 'github-actions@PROJECT.iam.gserviceaccount.com'
```

**Benefits:**
- ✅ No secrets stored in GitHub
- ✅ Temporary credentials
- ✅ More secure (recommended for production)

## Security Considerations

### What This Workflow Does NOT Do

- ❌ Store credentials in repository
- ❌ Automatically deploy infrastructure
- ❌ Run `terraform apply` (deployment is always manual)
- ❌ Access real cloud resources during validation

### What It DOES Do

- ✅ Validates Terraform syntax
- ✅ Checks code formatting
- ✅ Lints for best practices
- ✅ Scans for security issues
- ✅ Runs on every PR (quality gate)

### Why Manual Deployment?

**Cost Control:**
- Prevents accidental infrastructure creation
- Allows review before spending money

**Safety:**
- Human verification before changes
- No automated destruction of resources

**Demo Purposes:**
- Shows CI/CD patterns without actual deployment
- Portfolio demonstration without cloud costs

## CI/CD Best Practices Demonstrated

1. **Automated Validation** - Every PR is checked
2. **Matrix Builds** - Test multiple environments (AWS + GCP)
3. **Security Scanning** - tfsec catches vulnerabilities
4. **Linting** - TFLint enforces best practices
5. **Manual Gates** - Workflow dispatch for controlled testing
6. **No Secrets in Code** - Credentials never committed

## Troubleshooting

### "No valid credential sources found"

**This is expected!** The workflow doesn't have credentials configured.

**To fix (if you want plan to work):**
- Add credentials via GitHub Secrets (see above)
- Or use Terraform Cloud
- Or accept this as demo behavior

### TFLint or tfsec failures

**Fix the reported issues in your Terraform code.**

Common issues:
- Missing descriptions on variables
- Security group open to 0.0.0.0/0
- Unencrypted resources
- Deprecated syntax

### Workflow doesn't trigger

**Check:**
- Modified files match `paths:` filter (`.tf` or `.tfvars.example`)
- Branch is `dev` (for push) or PR targets `main`
- Workflow file syntax is valid YAML

## Further Reading

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [Terraform Cloud](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)
- [OIDC with GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

## State Management

### Current Setup (Local State)

This demo uses **local state** for simplicity:
- State files stored in `environments/{aws,gcp}/.terraform/`
- **Not suitable for teams or production**
- Gitignored (never committed)

### Production Recommendations

#### Option 1: S3 Backend (AWS) ⭐ Most Common

**Setup:**

1. Create S3 bucket:
```bash
aws s3 mb s3://my-terraform-state --region eu-west-1
```

2. Create DynamoDB table for locking:
```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

3. Update `environments/aws/providers.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "aws/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Benefits:**
- ✅ Centralized state
- ✅ State locking
- ✅ Encryption at rest
- ✅ Team collaboration

**Cost:** ~$0.02/month

---

#### Option 2: GCS Backend (GCP)

**Setup:**

1. Create bucket:
```bash
gsutil mb -p PROJECT_ID -l europe-west1 gs://my-terraform-state/
gsutil versioning set on gs://my-terraform-state/
```

2. Update `environments/gcp/providers.tf`:
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "gcp"
  }
}
```

**Benefits:**
- ✅ GCP-native
- ✅ Automatic locking
- ✅ Versioning

**Cost:** ~$0.02/month

---

#### Option 3: Terraform Cloud ⭐ Easiest

**Setup:**

1. Create account: [app.terraform.io](https://app.terraform.io)
2. Create workspace
3. Update providers.tf:
```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "demo-terraform-aws"
    }
  }
}
```

**Benefits:**
- ✅ No infrastructure
- ✅ Built-in locking
- ✅ UI for runs
- ✅ Cost estimation
- ✅ **Free for 5 users**

---

### Comparison

| Backend | Best For | Locking | Cost | Setup |
|---------|----------|---------|------|-------|
| **Local** | Solo dev | ❌ | Free | Trivial |
| **S3** | AWS teams | ✅ | $0.02/mo | Medium |
| **GCS** | GCP teams | ✅ | $0.02/mo | Medium |
| **Terraform Cloud** | Any | ✅ | Free tier | Easy |

---

### Why Not GitHub?

**Never store state in Git (even private repos):**

❌ State contains sensitive data
❌ No locking mechanism
❌ Large files (Git inefficient)
❌ Merge conflicts = disaster

**Use proper remote backends instead.**