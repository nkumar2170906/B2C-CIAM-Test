# =========================================================================
# 1. CORE TRANSIT GATEWAY ENGINE
# =========================================================================
/*
resource "aws_ec2_transit_gateway" "this" {
  description                     = "Production Ready Cross-Account Identity Router"
  auto_accept_shared_attachments  = "enable" # Automatically mounts the CIAM team's attachment
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  

  tags = merge(var.global_tags, {
    Name = "${var.environment}-tgw"
  })
}*/

# =========================================================================
# 1. DISCOVER THE CLIENT'S EXISTING CENTRALIZED DEVELOPMENT TGW
# =========================================================================
# Reads the pre-existing TGW ID directly from your runtime variables
/*
data "aws_ec2_transit_gateway" "this" {
  id = var.existing_transit_gateway_id
}*/

# =========================================================================
# 2. ATTACH YOUR NEW LOCAL VPC TO THEIR CENTRALIZED TGW
# =========================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  
  transit_gateway_id = var.tg_id  #Point to the discovered TGW ID instead of a managed resource
  vpc_id             = var.local_vpc_id
  subnet_ids         = var.local_private_subnet_ids

  tags = merge(var.global_tags, {
    Name = "${var.environment}-rhds-tgw-attachment"
  })
}

# =========================================================================
# 2. CLIENT ROUTE REQUIREMENTS: DYNAMIC ROUTE TO CENTRALIZED TGW
# =========================================================================

resource "aws_route" "tgw_first" {
  count                  = length(var.local_private_route_table_ids)
  route_table_id         = var.local_private_route_table_ids[count.index]
  destination_cidr_block = var.tgw_destination_cidr_block
  transit_gateway_id     = var.tg_id
}



/*
resource "aws_route" "tgw_first" {
    #count = length(aws_route_table.private)
    count                  = length(var.local_private_route_table_ids)
    #route_table_id = aws_route_table.private[count.index].id
    route_table_id         = var.local_private_route_table_ids[count.index]
    destination_cidr_block = "10.0.0.0/8"
    #transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway.id
    transit_gateway_id     = var.tg_id

}*/
/*
resource "aws_route" "tgw_second" {
    count = length(aws_route_table.private)
    route_table_id = aws_route_table.private[count.index].id
    destination_cidr_block = "172.16.0.0/12"
    transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway.id

}

resource "aws_route" "tgw_third" {
    count = length(aws_route_table.private)
    route_table_id = aws_route_table.private[count.index].id
    destination_cidr_block = "192.168.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway.id

}
*/
/*
# =========================================================================
# 3. ROUTE TRAFFIC TO THE CIAM VPC THROUGH THEIR TGW
# =========================================================================
resource "aws_route" "cross_account_return_path" {
  route_table_id         = var.local_private_route_table_id
  destination_cidr_block = var.external_ciam_vpc_cidr 
  transit_gateway_id     = data.aws_ec2_transit_gateway.this.id
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
*/