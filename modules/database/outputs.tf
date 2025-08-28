output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "db_instance_identifier" {
  description = "RDS instance identifier for monitoring"
  value       = aws_db_instance.main.identifier
}