output "aws-ip" {
  value = aws_instance.boundary-demo-aws.public_ip
}

output "gcp-ip" {
  value = google_compute_instance.boundary-demo-gcp.network_interface.0.access_config.0.nat_ip
}