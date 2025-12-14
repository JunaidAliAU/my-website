# main.tf - Working Configuration with Amazon Linux 2

provider "aws" {
  region = "us-west-2"
}

# Generate SSH Key
resource "tls_private_key" "flask_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS Key Pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "terraform-flask-key"
  public_key = tls_private_key.flask_key.public_key_openssh
  
  lifecycle {
    ignore_changes = [key_name]
  }
}

# Save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.flask_key.private_key_pem
  filename = "${path.module}/terraform-key.pem"
}

# Security Group
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow HTTP and SSH"

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
}

# EC2 Instance - Amazon Linux 2 (100% Free Tier compatible)
resource "aws_instance" "flask_server" {
  ami           = "ami-0f5ee92e2d63afc18"  # Amazon Linux 2 AMI - Free Tier eligible
  instance_type = "t4g.small  "               # Free Tier eligible
  
  key_name      = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  
  tags = {
    Name    = "Flask-App-Terraform"
    Project = "CI-CD-Pipeline"
  }

  # Install Docker on startup
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              EOF
}

# Output values
output "instance_ip" {
  value = aws_instance.flask_server.public_ip
}

output "ssh_command" {
  value = "ssh -i terraform-key.pem ec2-user@${aws_instance.flask_server.public_ip}"
}

output "website_url" {
  value = "http://${aws_instance.flask_server.public_ip}"
}
