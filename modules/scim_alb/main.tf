# =========================================================================
# 1. PUBLIC APPLICATION LOAD BALANCER (ALB)
# =========================================================================
resource "aws_lb" "scim" {
  name               = "${var.environment}-scim-alb"
  internal           = false # Public-facing internet edge gateway
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = merge(var.global_tags, {
    Name = "${var.environment}-scim-alb"
  })
}

# =========================================================================
# 2. TARGET BINDING GROUPS & APP COUPLING
# =========================================================================
resource "aws_lb_target_group" "scim_api" {
  name        = "${var.environment}-scim-tg"
  port        = var.backend_app_port # Port where the SCIM gateway application listens on the EC2 instances
  protocol    = "HTTP"               # Internal traffic from ALB to EC2 can traverse via clear text within the subnet layer
  vpc_id      = var.vpc_id
  target_type = "instance"

  #Production-Ready Session Affinity Configuration

  stickiness {
    type                   = "lb_cookie" # AWS automatically injects an encrypted cookie to track the user session
    cookie_duration        = var.cookie_duration_seconds # Customizable cookie lifespan passed down via variables
    enabled                = var.enable_stickiness
  }

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-scim-target-group"
  })
}

# Automatically maps the Master EC2 node instance to this target group
resource "aws_lb_target_group_attachment" "scim_master" {
  target_group_arn = aws_lb_target_group.scim_api.arn
  target_id        = var.master_instance_id # Direct inject parameter from the EC2 module outputs
  port             = var.backend_app_port
}

# =========================================================================
# 3. INTERNET ROUTING TRAFFIC LISTENERS
# =========================================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.scim.arn
  port              = "80"
  protocol          = "HTTP"

  # Production Best Practice: Automatically redirects plain text HTTP traffic to secure HTTPS (443)
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
