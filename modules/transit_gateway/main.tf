# =========================================================================
# 1. ATTACH YOUR NEW LOCAL VPC TO THEIR CENTRALIZED TGW
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

}

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
