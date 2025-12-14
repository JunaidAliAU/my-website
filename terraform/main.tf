# main.tf - Main Terraform configuration

provider "aws" {
  region = "us-east-1"
}

# Create SSH Key Pair
resource "tls_private_key" "flask_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "terraform-flask-key"
  public_key = tls_private_key.flask_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.flask_key.private_key_pem
  filename = "${path.module}/terraform-key.pem"
  file_permission = "0400"
}

# Create Security Group
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
}

# Create EC2 Instance
resource "aws_instance" "flask_server" {
  ami = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS (Free Tier eligible)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  
  tags = {
    Name = "Terraform-Flask-Server"
    Project = "CI-CD-Pipeline"
  }

  # Install Docker on instance startup
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF
}

# Output the public IP
output "instance_public_ip" {
  value = aws_instance.flask_server.public_ip
}

output "ssh_private_key_path" {
  value = local_file.private_key.filename
}
