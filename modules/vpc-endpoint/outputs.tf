output "secrets_manager_vpc_endpoint_id" {
  description = "The ID of the VPC Endpoint for Secrets Manager"
  value       = aws_vpc_endpoint.secrets_manager.id
}
