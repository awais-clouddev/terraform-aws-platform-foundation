# Setup and Usage

## Prerequisites

- Ubuntu / WSL
- Terraform >= 1.16
- AWS CLI v2
- Git
- Valid AWS authentication
- AWS region: `ap-south-1`

Verify AWS access:

```bash
aws sts get-caller-identity
```

## 1. Clone the Repository

```bash
git clone https://github.com/awais-clouddev/terraform-aws-platform-foundation.git
cd terraform-aws-platform-foundation
```

## 2. Bootstrap the Remote State Backend

The S3 backend must exist before the development environment can be initialized.

Initialize the bootstrap configuration:

```bash
terraform -chdir=bootstrap init
```

Validate it:

```bash
terraform -chdir=bootstrap validate
```

Review the plan:

```bash
terraform -chdir=bootstrap plan
```

Create the remote-state infrastructure:

```bash
terraform -chdir=bootstrap apply
```

The bootstrap configuration returns the generated S3 bucket name:

```bash
terraform -chdir=bootstrap output -raw state_bucket_name
```

## 3. Initialize the Development Environment

Capture the state bucket name:

```bash
STATE_BUCKET=$(terraform -chdir=bootstrap output -raw state_bucket_name)
```

Initialize the development environment using that bucket:

```bash
terraform -chdir=environments/dev init \
  -reconfigure \
  -backend-config="bucket=$STATE_BUCKET"
```

This keeps the repository reusable because the AWS account-specific bucket name is not hardcoded in `backend.tf`.

## 4. Format and Validate

```bash
terraform fmt -check -recursive
terraform -chdir=environments/dev validate
```

## 5. Review the Plan

```bash
terraform -chdir=environments/dev plan
```

## 6. Deploy

```bash
terraform -chdir=environments/dev apply
```

## Variables

Main configurable values include:

- `project_name`
- `environment`
- `vpc_cidr`
- `availability_zones`
- `public_subnet_cidrs`
- `private_subnet_cidrs`
- `instance_type`

Example configuration:

```text
environments/dev/terraform.tfvars.example
```

## Outputs

Terraform returns:

- VPC ID
- Public subnet IDs
- Private subnet IDs
- EC2 instance ID
- Application URL

View outputs:

```bash
terraform -chdir=environments/dev output
```

## Remote State

State is stored remotely in Amazon S3 with:

- Server-side AES256 encryption
- Versioning
- Public access blocked
- Native S3 state locking

State path:

```text
dev/terraform.tfstate
```

The S3 bucket name is supplied during `terraform init` rather than being hardcoded in the repository.

## Security

- No public SSH access
- HTTP TCP/80 only for the demonstration workload
- Terraform state excluded from Git
- Variable files excluded from Git
- Terraform plan files excluded from Git
- S3 state bucket private and encrypted
- Provider versions locked with `.terraform.lock.hcl`

## Destroy the Development Infrastructure

Destroy the workload infrastructure first:

```bash
terraform -chdir=environments/dev destroy
```

The remote-state bootstrap infrastructure is managed separately and should not be deleted before the development environment is destroyed.

## Backend Cleanup

The bootstrap S3 bucket is intentionally protected from accidental deletion.

Because versioning is enabled, old state object versions and delete markers may remain after the development infrastructure is destroyed.

Only remove the backend intentionally after:

1. The development infrastructure has been destroyed.
2. Terraform state is no longer required.
3. S3 object versions and delete markers have been safely removed.

For normal reusable environments, the remote-state backend can remain in place for future deployments.