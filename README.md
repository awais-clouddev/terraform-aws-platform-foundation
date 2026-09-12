# Terraform AWS Platform Foundation

A production-oriented, modular AWS infrastructure platform built with Terraform, demonstrating reusable Infrastructure as Code, remote state management, modular architecture, environment-specific configuration, drift detection, and automated infrastructure deployment.

## Architecture

The project provisions the following AWS infrastructure:

- Custom VPC
- 2 public subnets across 2 Availability Zones
- 2 private subnets across 2 Availability Zones
- Internet Gateway
- Public route table
- Private route table
- Route table associations
- Security Group
- EC2 web workload
- Amazon Linux 2023
- Nginx installed automatically through `user_data`
- S3 remote Terraform state
- S3 state locking
- S3 state versioning
- Server-side encryption
- S3 public access blocking

## Architecture Flow

```text
Internet
   |
   v
Internet Gateway
   |
   v
Custom VPC
   |
   +-----------------------------+
   |                             |
   v                             v
Public Subnet AZ-A          Public Subnet AZ-B
   |
   v
EC2 Web Server
   |
   v
Nginx
   |
   v
HTTP :80

Private Tier
   |
   +-----------------------------+
   |                             |
   v                             v
Private Subnet AZ-A         Private Subnet AZ-B
```

## Terraform Remote State

```text
Terraform
   |
   v
Amazon S3
   |
   +-- Remote State
   +-- State Locking
   +-- Versioning
   +-- Encryption
   +-- Public Access Blocked
```

## Repository Structure

```text
terraform-aws-platform-foundation/
├── bootstrap/
│   ├── main.tf
│   ├── providers.tf
│   ├── versions.tf
│   └── .terraform.lock.hcl
│
├── environments/
│   └── dev/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars.example
│       ├── variables.tf
│       ├── versions.tf
│       └── .terraform.lock.hcl
│
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── security/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   └── compute/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
├── docs/
│   ├── architecture.md
│   └── troubleshooting.md
│
├── evidence/
│   ├── final-plan.txt
│   ├── terraform-outputs.txt
│   └── terraform-state.txt
│
├── .gitignore
└── README.md
```

## Terraform Engineering Practices

This project demonstrates:

- Reusable Terraform modules
- Environment-specific configuration
- Infrastructure as Code
- Remote state management
- Native S3 state locking
- Provider version locking
- Terraform dependency management
- Resource references
- Terraform data sources
- Variable validation
- Outputs
- Consistent resource naming
- Consistent AWS tagging
- Multi-AZ network design
- Drift detection
- Declarative drift remediation
- Git-based infrastructure version control

## Modules

### Network Module

The network module manages:

- VPC
- Internet Gateway
- Public subnets
- Private subnets
- Public route table
- Private route table
- Route table associations
- Multi-AZ placement

### Security Module

The security module manages:

- Web Security Group
- HTTP access on TCP port 80
- Outbound traffic rules
- No public SSH access

### Compute Module

The compute module manages:

- Amazon Linux 2023 AMI discovery using a Terraform data source
- EC2 instance
- Security Group attachment
- Public subnet placement
- Nginx installation through `user_data`
- Application endpoint outputs

## Remote State Bootstrap

The `bootstrap/` Terraform configuration creates the S3 infrastructure required by the main Terraform environment.

The remote state bucket includes:

- Versioning
- AES256 server-side encryption
- Public access blocking
- Terraform state locking

The main environment stores state using:

```text
dev/terraform.tfstate
```

## Terraform Workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

The deployment lifecycle is:

```text
Terraform Code
      |
      v
terraform init
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
terraform apply
      |
      v
AWS Infrastructure
      |
      v
Terraform Remote State
```

## Deployment Validation

Terraform successfully deployed the infrastructure.

```text
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
```

The deployed application was verified using:

```bash
curl "$(terraform output -raw application_url)"
```

Successful response:

```html
<h1>Terraform AWS Platform Foundation</h1>
```

## Terraform State Validation

Terraform successfully tracked the deployed infrastructure, including:

- VPC
- Internet Gateway
- 4 subnets
- Route tables
- Route table associations
- Security Group
- EC2 instance
- Amazon Linux AMI data source

Terraform state was verified with:

```bash
terraform state list
```

## Infrastructure Drift Test

A controlled manual change was introduced outside Terraform by modifying the EC2 instance `Name` tag.

Terraform detected the drift:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Terraform identified:

```text
manual-drift-test
```

and planned to restore:

```text
terraform-aws-platform-foundation-dev-web
```

The configuration was restored using:

```bash
terraform apply -auto-approve
```

Final validation:

```text
No changes. Your infrastructure matches the configuration.
```

This demonstrates Terraform's ability to detect and remediate infrastructure drift.

## Security Considerations

The project includes the following security practices:

- No public SSH ingress
- Only HTTP TCP/80 exposed for the demonstration workload
- Terraform state stored remotely in S3
- S3 state encryption enabled
- S3 versioning enabled
- S3 public access blocked
- Terraform state files excluded from Git
- Terraform variable files excluded from Git
- Terraform plan files excluded from Git
- Temporary AWS CLI authentication used during development
- Infrastructure managed declaratively through Terraform

## Cost Considerations

The project was intentionally designed to remain cost-conscious.

It avoids unnecessary services such as:

- NAT Gateway
- Application Load Balancer
- Amazon RDS
- Amazon ECS
- Amazon ElastiCache

These services were intentionally excluded because the primary goal of this project is demonstrating professional Terraform and Infrastructure as Code engineering.

The EC2 workload exists only as a small infrastructure validation workload.

## Evidence

The `evidence/` directory contains deployment and validation evidence.

### Terraform Outputs

```text
evidence/terraform-outputs.txt
```

### Terraform State Resources

```text
evidence/terraform-state.txt
```

### Final Terraform Plan

```text
evidence/final-plan.txt
```

The final plan confirms:

```text
No changes. Your infrastructure matches the configuration.
```

## Infrastructure Cleanup

The development infrastructure can be removed using:

```bash
cd environments/dev
terraform destroy
```

The remote-state bootstrap infrastructure is managed separately inside:

```text
bootstrap/
```

This separation prevents accidental deletion of Terraform state while managing the application infrastructure.

## Project Goal

The purpose of this project is to demonstrate how AWS infrastructure can be professionally created, managed, validated, version-controlled, and recovered using Terraform instead of manually configuring resources through the AWS Console.

The project focuses on:

```text
Manual Infrastructure
        |
        v
Infrastructure as Code
        |
        v
Reusable Terraform Modules
        |
        v
Remote State Management
        |
        v
Automated AWS Infrastructure
        |
        v
Drift Detection and Recovery
```

## Skills Demonstrated

- Terraform
- Infrastructure as Code
- AWS
- VPC Networking
- EC2
- S3
- Security Groups
- Remote State
- State Locking
- Terraform Modules
- Terraform State
- Terraform Data Sources
- Terraform Variables
- Terraform Outputs
- Terraform Drift Detection
- Git
- Linux
- AWS CLI
