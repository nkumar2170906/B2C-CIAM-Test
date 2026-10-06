# =========================================================================
# 1. PUBLIC ROUTE 53 ZONE DISCOVERY
# =========================================================================

resource "aws_route53_zone" "public" {
  name = var.public_domain_name

  tags = merge(var.global_tags, {
    Name = "${var.environment}-public-hosted-zone"
  })
}

# =========================================================================
# 2. PRIVATE HOSTED ZONE CREATION (INTERNAL APP ROUTING)
# =========================================================================

resource "aws_route53_zone" "private" {
  for_each = var.private_domain_names
  name     = each.value

  vpc {
    vpc_id = var.local_vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }

  tags = merge(var.global_tags, {
        
    Name = "${var.environment}-${each.key}-private-zone"
  })
}

# =========================================================================
# 3. CROSS-ACCOUNT HANDSHAKE AUTHORIZATION
# =========================================================================
resource "aws_route53_vpc_association_authorization" "cross_account_auth" {
  for_each = var.private_domain_names
  zone_id  = aws_route53_zone.private[each.key].zone_id
  vpc_id     = var.external_vpc_id
  vpc_region = var.external_vpc_region
  #vpc_region = "eu-central-1" # Optimized to your same-region Frankfurt blueprint
}
