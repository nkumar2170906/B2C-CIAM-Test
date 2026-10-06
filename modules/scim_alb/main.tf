# =========================================================================
# 1. PUBLIC INTERNET-FACING APPLICATION LOAD BALANCER
# =========================================================================
resource "aws_lb" "this" {
  name               = "${var.environment}-scim-public-alb"
  load_balancer_type = "application"
  internal           = false # Enforces public internet-facing edge routing
  subnets            = var.public_subnet_ids
  security_groups    = var.security_group_ids

  tags = merge(var.global_tags, {
    Name = "${var.environment}-scim-public-alb"
  })
}

# =========================================================================
# 2. TARGET GROUP ROUTING TO PRIVATE BACKEND PORT 8443
# =========================================================================
resource "aws_lb_target_group" "scim_8443" {
  name        = "${var.environment}-tg-scim-8443"
  port        = var.backend_port # 🎯 MATCHES DIAGRAM: Routes traffic strictly to Port 8443
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    port                = var.backend_port
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-tg-scim-8443"
  })
}

# =========================================================================
# 3. TESTING MODE ONLY: PURE PORT 80 HTTP ROUTING STEP (NO SSL REQUIRED)
# =========================================================================
resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP" # Bypasses all ACM checks cleanly for your personal test env

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.scim_8443.arn
  }
}

resource "aws_lb_target_group_attachment" "scim_master" {
  target_group_arn = aws_lb_target_group.scim_8443.arn
  target_id        = var.master_instance_id  # Targets the Master node exclusively as per blueprint
  port             = var.backend_port
}

/*
############################################################################
# =========================================================================
# 3. INTERNET-FACING SECURE LISTENER AND BACKEND TARGET ATTACHMENTS
# =========================================================================
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_443" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.scim_8443.arn
  }
}
*/
####################################################################



