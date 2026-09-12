# Troubleshooting

This document records common issues encountered while building and operating this Terraform AWS project.

## AWS CLI Session Expired

If AWS CLI authentication expires, authenticate again:

```bash
aws login --remote --region ap-south-1
```

Verify authentication:

```bash
aws sts get-caller-identity
```

## Terraform Provider Download Timeout

Terraform may occasionally fail while downloading the AWS provider because of a network timeout or connectivity issue.

Retry:

```bash
terraform init
```

If the provider already exists in another initialized Terraform directory, Terraform may also reuse the locally cached provider depending on the environment.

After initialization, verify:

```bash
terraform validate
```

## Backend Initialization Required

If Terraform reports:

```text
Backend initialization required
```

reinitialize the backend:

```bash
terraform init -reconfigure
```

This is commonly required after changing backend configuration or switching Terraform root directories.

## Running Terraform From the Wrong Directory

The active Terraform environment for this project is:

```text
environments/dev
```

Running Terraform commands from the repository root may produce backend or configuration errors.

Use:

```bash
cd environments/dev
```

Then run Terraform commands such as:

```bash
terraform init
terraform validate
terraform plan
```

Alternatively:

```bash
terraform -chdir=environments/dev plan
```

## Missing Terraform Provider

If Terraform reports that required providers are not installed, run:

```bash
terraform init
```

Then verify:

```bash
terraform validate
```

Provider versions are locked using:

```text
.terraform.lock.hcl
```

## Stale Terraform Plan

A saved Terraform plan can become stale after infrastructure has already been changed.

Example error:

```text
Saved plan is stale
```

Generate a fresh plan:

```bash
terraform plan
```

If using a saved plan file:

```bash
terraform plan -out=dev.tfplan
terraform apply dev.tfplan
```

Do not reuse an old plan after the Terraform state has changed.

## Terraform Drift Detection

If an AWS resource is changed manually outside Terraform, run:

```bash
terraform plan
```

Terraform compares:

```text
Terraform configuration
        ↓
Terraform state
        ↓
Real AWS infrastructure
```

If drift exists, Terraform displays the difference.

To restore the infrastructure to the declared Terraform configuration:

```bash
terraform apply
```

After remediation, verify:

```bash
terraform plan
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

## Remote State Bucket Missing

The development environment uses an S3 backend.

The backend infrastructure must exist before initializing:

```text
environments/dev
```

The state bucket is created separately through:

```text
bootstrap/
```

If the backend bucket does not exist, create the bootstrap infrastructure first before initializing the development environment.

## State Lock

This project uses native S3 Terraform state locking:

```hcl
use_lockfile = true
```

If Terraform is actively using the state, another Terraform operation should wait until the lock is released.

Do not manually remove a lock unless you are certain no Terraform process is still running.

## S3 Bucket Cannot Be Deleted

A versioned S3 bucket may fail to delete with:

```text
BucketNotEmpty
```

because old object versions and delete markers remain.

For normal project operation, the Terraform remote-state bucket should be protected from accidental deletion.

Backend cleanup should only be performed intentionally after the workload infrastructure has already been destroyed.

## Final Validation

Before considering the environment healthy, run:

```bash
terraform fmt -check -recursive
terraform validate
terraform plan
```

A healthy deployed environment should finish with:

```text
No changes. Your infrastructure matches the configuration.
```