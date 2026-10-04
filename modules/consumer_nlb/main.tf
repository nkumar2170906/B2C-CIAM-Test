# =========================================================================
# 1. PRIVATE CONSUMER NETWORK LOAD BALANCER (NLB)
# =========================================================================
resource "aws_lb" "consumer" {
  name               = "${var.environment}-consumer-nlb"
  internal           = true # Strictly private internal load balancer
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids # Hosted in the secure private subnet tier

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = merge(var.global_tags, {
    Name = "${var.environment}-consumer-nlb"
  })
}

# =========================================================================
# 2. SECURE LDAPS READ TARGET GROUP WITH LAYER 4 STICKINESS
# =========================================================================
resource "aws_lb_target_group" "consumer_ldaps" {
  name        = "${var.environment}-consumer-ldaps-tg"
  port        = 636 # Secure LDAPS standard listening port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # WOW Factor: Layer 4 Source IP Session Affinity for directory query traffic
  stickiness {
    type    = "source_ip" # Binds persistence strictly via incoming client IP footprints
    enabled = var.enable_session_stickiness
  }

  health_check {
    enabled             = true
    port                = "traffic-port"
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-consumer-ldaps-tg"
  })
}

# Automatically hooks the Slave directory server instance node to this target group
resource "aws_lb_target_group_attachment" "slave_node" {
  target_group_arn = aws_lb_target_group.consumer_ldaps.arn
  target_id        = var.slave_instance_id # Direct output inject from your EC2 module
  port             = 636
}

# =========================================================================
# 3. LAYER 4 ROUTING NETWORK LISTENERS
# =========================================================================
resource "aws_lb_listener" "ldaps" {
  load_balancer_arn = aws_lb.consumer.arn
  port              = 636
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consumer_ldaps.arn
  }
}
