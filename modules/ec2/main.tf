
# =========================================================================
# 1. PRIVATE COMPUTE CLUSTER INSTANCES MODULES
# =========================================================================
resource "aws_instance" "this" {
  for_each = var.cluster_nodes

  ami                    = var.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  root_block_device {
    volume_size           = each.value.volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${each.key}"
    Role = each.value.role
  })
}

# =========================================================================
# 2. SEPARATE NETWORK INTERFACE (PROVISIONED EXCLUSIVELY FOR MASTER & SCIM)
# =========================================================================
resource "aws_network_interface" "secondary" {
  for_each = { for k, v in var.cluster_nodes : k => v if v.allocate_secondary_eni }

  subnet_id       = var.subnet_id
  security_groups = var.security_group_ids

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${each.key}-secondary-eni"
  })
}

resource "aws_network_interface_attachment" "secondary_attach" {
  for_each = { for k, v in var.cluster_nodes : k => v if v.allocate_secondary_eni }

  instance_id          = aws_instance.this[each.key].id
  network_interface_id = aws_network_interface.secondary[each.key].id
  device_index         = 1 # Maps strictly to eth1 for SCIM Gateway traffic boundaries
}
