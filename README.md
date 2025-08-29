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

## Complete Terraform Web Infrastructure Project

A comprehensive guide to building a production-ready, multi-environment web application infrastructure on AWS using Terraform with modular architecture.

## Architecture Overview

This project creates a robust 3-tier web application infrastructure:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Tier      │    │   App Tier      │    │  Database Tier  │
│                 │    │                 │    │                 │
│ • Load Balancer │───▶│ • EC2 Instances │───▶│ • RDS MySQL     │
│ • Public Subnet │    │ • Auto Scaling  │    │ • Private Subnet│
│ • Internet GW   │    │ • Private Subnet│    │ • Multi-AZ      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Features
- Multi-environment support (dev/prod)
- Auto-scaling with CloudWatch monitoring
- High availability across multiple AZs
- Secure network architecture with public/private subnets
- Modular Terraform code for reusability
- Load balancing with health checks

## Project Structure

```
terraform-web-platform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── README.md
└── .gitignore
```

## Quick Start

### Prerequisites

1. **Install Terraform**
   ```bash
   # Download from https://terraform.io/downloads
   # Add to PATH
   terraform --version  # Verify installation
   ```

2. **Install AWS CLI**
   ```bash
   # Download from https://aws.amazon.com/cli/
   aws --version  # Verify installation
   ```

3. **Configure AWS Credentials**
   ```bash
   aws configure
   # Enter your Access Key ID, Secret Access Key, and Region (us-east-1)
   ```

### Project Setup

1. **Clone and setup project structure**
   ```bash
   mkdir terraform-web-platform && cd terraform-web-platform
   
   # Create directory structure
   mkdir -p environments/{dev,prod} modules/{networking,compute,database and monitoring}
   
   # Create essential files
   touch README.md .gitignore
   touch environments/dev/{main.tf,variables.tf,terraform.tfvars,outputs.tf}
   touch environments/prod/{main.tf,variables.tf,terraform.tfvars,outputs.tf}
   touch modules/{networking,compute,database and monitoring}/{main.tf,variables.tf,outputs.tf}
   ```

## Deployment Guide

### Development Environment

1. **Navigate to dev environment**
   ```bash
   cd environments/dev
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```
   This downloads the AWS provider and sets up the working directory.

3. **Format and validate code**
   ```bash
   terraform fmt -recursive  # Format code
   terraform validate        # Validate syntax
   ```

4. **Plan deployment**
   ```bash
   terraform plan
   ```
   Review the execution plan. You should see ~38 resources to be created.

5. **Apply configuration**
   ```bash
   terraform apply
   ```
   Type `yes` when prompted. Deployment takes 10-15 minutes.

6. **Verify deployment**
   ```bash
   terraform output
   ```
   Note the ALB DNS name for testing.

### Production Environment

Repeat the same steps in `environments/prod`:
```bash
cd ../prod
terraform init
terraform validate
terraform plan
terraform apply
```

##  Configuration Details

### Environment Variables

**Development (environments/dev/terraform.tfvars)**
```hcl
environment = "dev"
vpc_cidr    = "10.0.0.0/16"

# Minimal resources for cost optimization
instance_type     = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 1
db_instance_class = "db.t3.micro"
```

**Production (environments/prod/terraform.tfvars)**
```hcl
environment = "prod"
vpc_cidr    = "10.1.0.0/16"

# Higher capacity for production workloads
instance_type     = "t3.small"
min_size         = 2
max_size         = 5
desired_capacity = 3
db_instance_class = "db.t3.small"
```

##  Testing and Verification

### Application Testing
1. **Access the application**
   ```bash
   # Get ALB DNS name
   terraform output alb_dns_name
   
   # Open in browser
   http://[ALB-DNS-NAME]
   ```
   You should see: "[environment] environment"

2. **Test auto-scaling**
   ```bash
   # Generate load using Apache Bench (if installed)
   ab -n 1000 -c 10 http://[ALB-DNS-NAME]/
   
   # Monitor in AWS Console:
   # - CloudWatch → EC2 metrics
   # - EC2 → Auto Scaling Groups
   ```

### Infrastructure Verification
- **VPC**: Check subnets, route tables, internet gateway, NAT gateway
- **EC2**: Verify instances, security groups, load balancer
- **RDS**: Confirm database in private subnets (not publicly accessible)
- **CloudWatch**: Review metrics and auto-scaling activities

## ❌ Common Errors and Solutions

### 1. AWS Provider Configuration Issues

**Error:**
```
Error: No valid credential sources found for AWS Provider
```

**Solution:**
```bash
# Verify AWS credentials
aws configure list

# If not configured:
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)
```

### 2. Security Group Rule Conflicts

**Error:**
```
Error: [WARN] Multiple configuration blocks for aws_security_group
```

**Solution:**
Based on AWS best practices, avoid mixing inline rules with separate rule resources. Use either:
- Inline rules within `aws_security_group` (current approach)
- Separate `aws_security_group_rule` resources

### 3. Availability Zone Errors

**Error:**
```
Error: Invalid availability zone
```

**Solution:**
```bash
# Check available AZs for your region
aws ec2 describe-availability-zones --region us-east-1

# Update terraform.tfvars with valid AZs
availability_zones = ["us-east-1a", "us-east-1b"]
```

### 4. Insufficient Permissions

**Error:**
```
Error: UnauthorizedOperation: You are not authorized to perform this operation
```

**Solution:**
Ensure your AWS user/role has these permissions:
- EC2FullAccess
- VPCFullAccess
- RDSFullAccess
- ApplicationLoadBalancerFullAccess
- CloudWatchFullAccess

### 5. Module Path Issues

**Error:**
```
Error: Module not found
```

**Solution:**
```bash
# Verify module paths in main.tf
source = "../../modules/networking"  # Correct relative path

# Run from correct directory
cd environments/dev  # Not from project root
```

##  Cleanup

**⚠ Important: Destroy resources to avoid AWS charges!**

```bash
# In each environment directory
cd environments/dev
terraform destroy

cd ../prod
terraform destroy
```

Type `yes` to confirm deletion. This process takes 5-10 minutes.

##  Monitoring and Maintenance

### CloudWatch Monitoring
- **CPU Utilization**: Monitors auto-scaling triggers
- **ALB Health Checks**: Ensures application availability
- **RDS Performance**: Database metrics and connections


##  Security Best Practices

### Implemented Security Measures
-  Private subnets for application and database tiers
-  Security groups with least privilege access
-  Database encryption at rest
-  No direct internet access to database

## 📞 Troubleshooting

### Debug Commands
```bash
# Check Terraform state
terraform show

# List resources
terraform state list

# Inspect specific resource
terraform state show aws_instance.example

# Enable debug logging
export TF_LOG=DEBUG
terraform apply
```



##  Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/)



---

**Cost Warning**: This infrastructure creates billable AWS resources. Always run `terraform destroy` after testing to avoid unexpected charges.
