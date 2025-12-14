# main.tf - Updated for Amazon Linux 2023 and t3.micro

provider "aws" {
  region = "us-east-1"
}

# Create SSH Key Pair (same as you created manually)
resource "tls_private_key" "flask_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "manual-key"  # Same name as you created
  public_key = tls_private_key.flask_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.flask_key.private_key_pem
  filename = "${path.module}/terraform-key.pem"
}

# Security Group
resource "aws_security_group" "flask_sg" {
  name        = "terraform-flask-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask-app-security-group"
  }
}

# EC2 Instance - Using your selected AMI and instance type
resource "aws_instance" "flask_server" {
  ami           = "ami-068c0051b15cdb816"  # Amazon Linux 2023 Kernel 6.1
  instance_type = "t3.micro"               # t3.micro (not free tier)
  
  key_name      = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  
  tags = {
    Name    = "Flask-App-Terraform"
    Project = "CI-CD-Pipeline"
    AMI     = "Amazon-Linux-2023"
  }

  # Install Docker on Amazon Linux 2023
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              EOF
}

# Output values
output "instance_public_ip" {
  value = aws_instance.flask_server.public_ip
}

output "ssh_connection" {
  value = "ssh -i terraform-key.pem ec2-user@${aws_instance.flask_server.public_ip}"
}

output "website_url" {
  value = "http://${aws_instance.flask_server.public_ip}"
}

output "cost_note" {
  value = "Note: t3.micro instance costs approx $0.0104 per hour (not free tier)"
}
