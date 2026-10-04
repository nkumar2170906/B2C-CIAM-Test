# =========================================================================
# 1. PUBLIC ROUTE 53 ZONE DISCOVERY
# =========================================================================
# Looks up the pre-registered corporate top-level domain owned by the client
data "aws_route53_zone" "public" {
  name         = var.public_domain_name
  private_zone = false
}

# =========================================================================
# 2. PRIVATE HOSTED ZONE CREATION (INTERNAL APP ROUTING)
# =========================================================================
resource "aws_route53_zone" "private" {
  name = var.private_domain_name

  # Initial mandatory link to your local RHDS VPC network
  vpc {
    vpc_id = var.local_vpc_id
  }

  # Prevents Terraform from stripping out the
  # CIAM team's VPC link later when they run their association codebase.
  lifecycle {
    ignore_changes = [vpc]
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-private-hosted-zone"
  })
}

# =========================================================================
# 3. CROSS-ACCOUNT HANDSHAKE AUTHORIZATION (THE VALUE ADD)
# =========================================================================
# This resource runs entirely inside your account. It unlocks the security gate
# and explicitly tells AWS: "Allow this external CIAM VPC ID to attach to my zone."
resource "aws_route53_vpc_association_authorization" "cross_account_auth" {
  zone_id = aws_route53_zone.private.id
  vpc_id  = var.external_vpc_id
}
