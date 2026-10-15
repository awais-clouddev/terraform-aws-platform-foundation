data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  # checkov:skip=CKV_AWS_88:Public HTTP demonstration workload; private hosting requires a different ingress architecture.
  # checkov:skip=CKV_AWS_126:Basic EC2 monitoring accepted for this lab; detailed monitoring is future scope.
  # checkov:skip=CKV_AWS_135:EBS optimization depends on the selected instance type; verify support before a future deployment.
  # checkov:skip=CKV2_AWS_41:Workload makes no AWS API calls; no instance role or AWS credentials are required.
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              set -Eeuo pipefail
              trap 'echo "ERROR: Instance setup failed at line $LINENO" >&2' ERR

              dnf install -y nginx
              printf '%s\n' '<h1>Terraform AWS Platform Foundation</h1>' > /usr/share/nginx/html/index.html
              nginx -t
              systemctl enable --now nginx
              systemctl is-active --quiet nginx
              curl --fail --silent --show-error --connect-timeout 3 --max-time 10 http://127.0.0.1/ >/dev/null
              echo "Instance setup completed successfully"
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}