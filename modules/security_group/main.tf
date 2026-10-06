# =========================================================================
# 1. APPLICATION SECURITY GROUP CONTAINER 
# =========================================================================
resource "aws_security_group" "this" {
  name        = "${var.environment}-${var.sg_name}-sg"
  description = "Managed by Terraform - Production Ready Default Layer for ${var.sg_name}"
  vpc_id      = var.vpc_id
  
  # Currently evaluates to a default-deny posture if ingress_rules list is empty.
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Standard default egress: Allows all outbound traffic for updates/patching
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.sg_name}-sg"
  })
}
