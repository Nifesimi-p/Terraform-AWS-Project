variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for monitoring"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix for monitoring"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "db_instance_identifier" {
  description = "RDS instance identifier"
  type        = string
}

variable "notification_email" {
  description = "Email for notifications"
  type        = string
  default     = ""
}