output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.compute.alb_dns_name
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_endpoint
}

output "monitoring_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}