# =========================================================================
# 1. PRIVATE MASTER NETWORK LOAD BALANCER (NLB)
# =========================================================================
resource "aws_lb" "master" {
  name               = "${var.environment}-master-nlb"
  internal           = true # Strictly private internal load balancer
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids # Mounted to the secure internal network tier

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = merge(var.global_tags, {
    Name = "${var.environment}-master-nlb"
  })
}

# =========================================================================
# 2. SECURE LDAPS TARGET GROUP TIER WITH LAYER 4 STICKINESS
# =========================================================================
resource "aws_lb_target_group" "master_ldaps" {
  name        = "${var.environment}-master-ldaps-tg"
  port        = 636 # Secure LDAPS standard listening port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Layer 4 Source IP Session Affinity for secure directory writes
  stickiness {
    type    = "source_ip" # Binds persistence strictly via incoming client IP footprints
    enabled = var.enable_session_stickiness
  }

  # High-Availability Layer 4 health tracking
  health_check {
    enabled             = true
    port                = "traffic-port"
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-master-ldaps-tg"
  })
}

# Automatically couples the explicit Master directory server instance node to this NLB target stream
resource "aws_lb_target_group_attachment" "master_node" {
  target_group_arn = aws_lb_target_group.master_ldaps.arn
  target_id        = var.master_instance_id # Direct output inject from your EC2 module
  port             = 636
}

# =========================================================================
# 3. LAYER 4 ROUTING NETWORK LISTENERS
# =========================================================================
resource "aws_lb_listener" "ldaps" {
  load_balancer_arn = aws_lb.master.arn
  port              = 636
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.master_ldaps.arn
  }
}
