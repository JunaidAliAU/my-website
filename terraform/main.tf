# terraform/main.tf - With security group resource

provider "aws" {
  region = "us-east-1"
}

# 1. Existing Key Pair
resource "aws_key_pair" "existing_key" {
  key_name   = "manual-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCu7YqTZZZDdxYr359LTaGKxgJpiEX6GNi6eZko0ke3G/4DM9FHwsckMq0aaaGovZdvpZo/EF3be4z7eFZyKQXcWssDLJWn9gZRpd7LpKbfIHhfbqgVLzBAJIZuL5nNQ2gktJboiT+9Cwu9A7o7IGzeZLJoXU+w02ew9lRyxBsoBzBFaPaX9e3eLCbyb/A2/q7ekycAVPYFJCxEb5EdN7OW6e4heKcQ+l8Iw25ozBFFN3VJ2G/x3eS5bjl3oklQj2zvBiUl4EhMsFI2KyP0dHtKBoAuBsdsdQGQAkGbZ2c7AtYgGp5Q9WUoDwVF7uQ/JXAExxoK8pEPVl2NQDb0MA4D"
}

# 2. Existing Security Group (ADD THIS)
resource "aws_security_group" "existing_sg" {
  name        = "launch-wizard-1"
  description = "Existing security group"
  
  # Terraform will import existing rules
  # We don't define rules here, they'll come from import
}

# 3. Existing EC2 Instance
resource "aws_instance" "flask_server" {
  ami           = "ami-068c0051b15cdb816"
  instance_type = "t3.micro"
  
  key_name               = aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [aws_security_group.existing_sg.id]
  subnet_id              = "subnet-0d9a3621e13007d17"
  
  tags = {
    Name    = "Flask-App-Terraform"
    Project = "CI-CD-Pipeline"
  }
}

output "instance_ip" {
  value = aws_instance.flask_server.public_ip
}

output "website_url" {
  value = "http://${aws_instance.flask_server.public_ip}"
}
