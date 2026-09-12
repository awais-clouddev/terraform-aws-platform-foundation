# Setup and Usage

## Prerequisites

- Ubuntu / WSL
- Terraform >= 1.16
- AWS CLI v2
- Git
- Valid AWS authentication
- AWS region: `ap-south-1`

## Initialize

```bash
cd environments/dev
terraform init
```

## Validate

```bash
terraform fmt -recursive
terraform validate
```

## Plan

```bash
terraform plan
```

## Deploy

```bash
terraform apply
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
terraform output
```

## Remote State

State is stored remotely in Amazon S3 with:

- Server-side encryption
- Versioning
- Public access blocked
- Native S3 state locking

State path:

```text
dev/terraform.tfstate
```

## Security

- No public SSH access
- HTTP TCP/80 only for demo workload
- Terraform state excluded from Git
- Variable files excluded from Git
- Terraform plan files excluded from Git
- S3 state bucket private and encrypted

## Cleanup

```bash
terraform destroy
```
