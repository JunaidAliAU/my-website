# outputs.tf - Output values

output "website_url" {
  value = "http://${aws_instance.flask_server.public_ip}"
}

output "ssh_command" {
  value = "ssh -i terraform-key.pem ubuntu@${aws_instance.flask_server.public_ip}"
}
