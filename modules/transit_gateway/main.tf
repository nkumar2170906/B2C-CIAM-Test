# =========================================================================
# 1. CORE TRANSIT GATEWAY ENGINE
# =========================================================================
resource "aws_ec2_transit_gateway" "this" {
  description                     = "Production Ready Cross-Account Identity Router"
  auto_accept_shared_attachments  = "enable" # Automatically mounts the CIAM team's attachment
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  

  tags = merge(var.global_tags, {
    Name = "${var.environment}-tgw"
  })
}

# =========================================================================
# 2. LOCAL VPC ATTACHMENT BINDING
# =========================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "local_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = var.local_vpc_id
  subnet_ids         = var.local_private_subnet_ids # HA network endpoints

  tags = merge(var.global_tags, {
    Name = "${var.environment}-tgw-attachment"
  })
}

# =========================================================================
# 3. STATIC RETURN ROUTE DEFINITION
# =========================================================================
resource "aws_route" "cross_account_return_path" {
  route_table_id         = var.local_private_route_table_id
  destination_cidr_block = var.external_vpc_cidr # Directs packets back to CIAM spaces
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

# =========================================================================
# 4. AWS RESOURCE ACCESS MANAGER (RAM) - THE ASYNCHRONOUS BRIDGE
# =========================================================================
resource "aws_ram_resource_share" "tgw_share" {
  name                      = "${var.environment}-tgw-resource-share"
  allow_external_principals = true # Required since CIAM is a separate AWS Account

  tags = merge(var.global_tags, {
    Name = "${var.environment}-tgw-ram-share"
  })
}

# Maps the Transit Gateway to the RAM share container
resource "aws_ram_resource_association" "tgw_association" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}

# Securely targets the external CIAM team's 12-digit AWS Account ID
resource "aws_ram_principal_association" "ciam_account_bind" {
  principal          = var.external_aws_account_id
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
}
