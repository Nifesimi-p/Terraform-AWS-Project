# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_security_group_id]
  subnets           = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name     = "${var.environment}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name        = "${var.environment}-app-tg"
    Environment = var.environment
  }
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [var.app_security_group_id]

  # Enhanced User Data Script for Launch Template
# Replace the user_data section in modules/compute/main.tf with this:

user_data = base64encode(<<-EOF
#!/bin/bash

# Update system and install Apache
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "Private Instance")
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create enhanced HTML page
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Multi-Environment Infrastructure Demo</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            max-width: 600px;
            width: 90%;
            text-align: center;
        }
        
        .env-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 25px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .env-dev {
            background: #4CAF50;
            color: white;
        }
        
        .env-prod {
            background: #FF5722;
            color: white;
        }
        
        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.2em;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .info-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .info-card h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 1.1em;
        }
        
        .info-card p {
            color: #666;
            font-family: 'Courier New', monospace;
            background: #e9ecef;
            padding: 8px;
            border-radius: 5px;
            word-break: break-all;
        }
        
        .status {
            margin-top: 30px;
            padding: 15px;
            background: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 8px;
            color: #155724;
        }
        
        .footer {
            margin-top: 30px;
            color: #888;
            font-size: 0.9em;
        }
        
        .refresh-btn {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
            transition: background 0.3s;
        }
        
        .refresh-btn:hover {
            background: #5a6fd8;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 20px;
                margin: 20px;
            }
            
            h1 {
                font-size: 2em;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="env-badge ENV_CLASS">ENV_NAME Environment</div>
        
        <h1>🚀 Infrastructure Demo</h1>
        <p class="subtitle">Auto-Scaling Web Application</p>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>🖥️ Instance Details</h3>
                <p>INSTANCE_ID_PLACEHOLDER</p>
            </div>
            
            <div class="info-card">
                <h3>📍 Availability Zone</h3>
                <p>AZ_PLACEHOLDER</p>
            </div>
            
            <div class="info-card">
                <h3>⚙️ Instance Type</h3>
                <p>INSTANCE_TYPE_PLACEHOLDER</p>
            </div>
            
            <div class="info-card">
                <h3>🌐 IP Addresses</h3>
                <p>Private: LOCAL_IP_PLACEHOLDER<br>
                Public: PUBLIC_IP_PLACEHOLDER</p>
            </div>
        </div>
        
        <div class="status">
            <strong>✅ Status:</strong> Application is running successfully with auto-scaling enabled!
        </div>
        
        <button class="refresh-btn" onclick="location.reload()">
            🔄 Refresh to See Different Instance
        </button>
        
        <div class="footer">
            <p>Deployed with Terraform • Load Balanced • Auto-Scaled</p>
            <p>Last updated: <span id="timestamp"></span></p>
        </div>
    </div>
    
    <script>
        // Set timestamp
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        
        // Auto-refresh every 30 seconds to show load balancing
        setTimeout(function() {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
HTML

# Replace placeholders with actual values
sed -i "s/ENV_NAME/${var.environment}/g" /var/www/html/index.html
sed -i "s/ENV_CLASS/env-${var.environment}/g" /var/www/html/index.html
sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/AZ_PLACEHOLDER/$AZ/g" /var/www/html/index.html
sed -i "s/INSTANCE_TYPE_PLACEHOLDER/$INSTANCE_TYPE/g" /var/www/html/index.html
sed -i "s/LOCAL_IP_PLACEHOLDER/$LOCAL_IP/g" /var/www/html/index.html
sed -i "s/PUBLIC_IP_PLACEHOLDER/$PUBLIC_IP/g" /var/www/html/index.html

# Create a health check endpoint
echo "OK" > /var/www/html/health

# Create a simple API endpoint to show load balancing
cat > /var/www/html/api.html << 'API'
{
  "status": "healthy",
  "environment": "ENV_NAME",
  "instance_id": "INSTANCE_ID_PLACEHOLDER",
  "availability_zone": "AZ_PLACEHOLDER",
  "timestamp": "$(date -Iseconds)"
}
API

# Replace placeholders in API
sed -i "s/ENV_NAME/${var.environment}/g" /var/www/html/api.html
sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/api.html
sed -i "s/AZ_PLACEHOLDER/$AZ/g" /var/www/html/api.html

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache to ensure everything is working
systemctl restart httpd
EOF
)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-app-instance"
      Environment = var.environment
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.environment}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.environment}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# CloudWatch Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

# CloudWatch Alarm - Low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.environment}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}