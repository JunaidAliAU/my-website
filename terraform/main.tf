# terraform/main.tf - Perfect alignment with existing instance

provider "aws" {
  region = "us-east-1"
}

# Existing Key Pair (jo aap ne manually banaya)
resource "aws_key_pair" "existing_key" {
  key_name   = "manual-key"  # ✅ Aap ka key pair name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCu7YqTZZZDdxYr359LTaGKxgJpiEX6GNi6eZko0ke3G/4DM9FHwsckMq0aaaGovZdvpZo/EF3be4z7eFZyKQXcWssDLJWn9gZRpd7LpKbfIHhfbqgVLzBAJIZuL5nNQ2gktJboiT+9Cwu9A7o7IGzeZLJoXU+w02ew9lRyxBsoBzBFaPaX9e3eLCbyb/A2/q7ekycAVPYFJCxEb5EdN7OW6e4heKcQ+l8Iw25ozBFFN3VJ2G/x3eS5bjl3oklQj2zvBiUl4EhMsFI2KyP0dHtKBoAuBsdsdQGQAkGbZ2c7AtYgGp5Q9WUoDwVF7uQ/JXAExxoK8pEPVl2NQDb0MA4D"  # ✅ Aap ki public key
}

# Existing Security Group
resource "aws_security_group" "existing_sg" {
  name        = "launch-wizard-1"  # ✅ Existing security group name
  description = "Existing security group for Flask app"
  
  # Rules automatically match karenge existing se
}

# Manage Existing EC2 Instance
resource "aws_instance" "flask_server" {
  # ✅ EXACTLY same as your running instance
  ami           = "ami-068c0051b15cdb816"  # Amazon Linux 2023
  instance_type = "t3.micro"               # t3.micro
  
  # ✅ Existing key pair
  key_name = aws_key_pair.existing_key.key_name
  
  # ✅ Existing security group
  vpc_security_group_ids = [aws_security_group.existing_sg.id]
  
  # ✅ Same subnet
  subnet_id = "subnet-0d9a3621e13007d17"
  
  tags = {
    Name    = "Flask-App-Terraform"
    Project = "CI-CD-Pipeline"
    Managed = "Terraform"
  }
}

# Outputs
output "instance_public_ip" {
  value = aws_instance.flask_server.public_ip
  description = "Public IP address of the instance"
}

output "website_url" {
  value = "http://${aws_instance.flask_server.public_ip}"
  description = "URL to access the Flask website"
}

output "ssh_command" {
  value = "ssh -i manual-key.pem ec2-user@${aws_instance.flask_server.public_ip}"
  description = "SSH command to connect to instance"
}
