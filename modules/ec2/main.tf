# =========================================================================
# 1. CORE EC2 COMPUTE CLUSTER NODES
# =========================================================================
resource "aws_instance" "this" {
  for_each = var.cluster_nodes

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  # Enterprise Standard Root Block Device Configuration
  root_block_device {
    volume_size           = each.value.volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false # Prevents data loss if an instance is accidentally terminated
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${each.key}"
    Role = each.value.role
  })
}

# =========================================================================
# 2. PERSISTENT NETWORKING BOUNDS (CONDITIONAL ELASTIC IPs)
# =========================================================================

# Step A: Allocate Elastic IPs on AWS for instances that require a persistent public/static footprint
resource "aws_eip" "this" {
  for_each = { for k, v in var.cluster_nodes : k => v if v.allocate_eip }

  domain = "vpc"

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${each.key}-eip"
  })
}

# Step B: Securely bind the allocated Elastic IP directly to the active cluster node instance
resource "aws_eip_association" "this" {
  for_each = { for k, v in var.cluster_nodes : k => v if v.allocate_eip }

  instance_id   = aws_instance.this[each.key].id
  allocation_id = aws_eip.this[each.key].id
}

