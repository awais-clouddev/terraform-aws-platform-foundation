resource "aws_security_group" "web" {
  # checkov:skip=CKV_AWS_260:Public HTTP serves a demonstration page only; HTTPS is required for a production application.
  # checkov:skip=CKV2_AWS_5:Group is attached through compute.security_group_id in environments/dev/main.tf; scanner does not resolve this relationship.
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Allow HTTP traffic to web workload"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP package repositories"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS package repositories"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-web-sg"
  }
}