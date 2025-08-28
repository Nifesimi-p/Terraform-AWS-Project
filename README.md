# Multi-Environment Web Application Infrastructure

This project creates a production-ready web application infrastructure with auto-scaling capabilities using Terraform.

## Architecture
- VPC with public and private subnets across 2 AZs
- Application Load Balancer for traffic distribution
- Auto Scaling Group with EC2 instances
- RDS MySQL database
- CloudWatch monitoring and alarms
- SNS notifications for critical alerts
- Comprehensive monitoring dashboard

## Usage

1. Navigate to desired environment:
   ```bash
   cd environments/dev
   # or
   cd environments/prod