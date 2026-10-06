
# =========================================================================
# 1. PRIVATE INTERNAL NETWORK LOAD BALANCER
# =========================================================================
resource "aws_lb" "this" {
  name               = "${var.environment}-master-directory-nlb"
  load_balancer_type = "network"
  internal           = true # 🎯 Enforces strict internal private network boundaries
  subnets            = [var.subnet_id]

  enable_cross_zone_load_balancing = true

  tags = merge(var.global_tags, {
    Name = "${var.environment}-master-nlb"
  })
}

# =========================================================================
# 2. TARGET GROUP WITH SOURCE IP STICKINESS
# =========================================================================
resource "aws_lb_target_group" "ldaps_636" {
  name        = "${var.environment}-tg-master-636"
  port        = 636
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Enforces strict stickiness loops based on incoming source IPs
  stickiness {
    enabled = true
    type    = "source_ip"
  }

  health_check {
    port                = 636
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-tg-master-636"
  })
}

# =========================================================================
# 3. LAYER 4 LISTENERS AND TARGET ATTACHMENTS
# =========================================================================
resource "aws_lb_listener" "ldaps" {
  load_balancer_arn = aws_lb.this.arn
  port              = 636
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ldaps_636.arn
  }
}

resource "aws_lb_target_group_attachment" "master_binding" {
  target_group_arn = aws_lb_target_group.ldaps_636.arn
  target_id        = var.master_instance_id
  port             = 636
}

