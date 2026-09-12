# Architecture

## Overview

This project uses Terraform to provision a modular AWS platform foundation in `ap-south-1`.

## Network

- 1 custom VPC
- 2 public subnets
- 2 private subnets
- 2 Availability Zones
- Internet Gateway
- Public route table
- Private route table
- Route table associations

## Security

- Dedicated web Security Group
- HTTP TCP/80 allowed
- No public SSH access
- Outbound traffic allowed for workload requirements

## Compute

- Amazon Linux 2023
- EC2 instance
- AMI discovered dynamically using a Terraform data source
- Nginx installed using `user_data`

## State Management

Terraform remote state is stored in Amazon S3 with:

- Versioning
- AES256 encryption
- Public access blocking
- Native state locking

## Module Design

```text
modules/
├── network/
├── security/
└── compute/
