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
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Terraform AWS Platform Foundation</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}