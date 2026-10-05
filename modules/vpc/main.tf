# =========================================================================
# 1. CORE VIRTUAL PRIVATE CLOUD (VPC)
# =========================================================================

resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = merge(var.global_tags, {
        Name ="${var.environment}-${var.vpc_name}-vpc"
    })
}

# =========================================================================
# 2. INTERNET GATEWAY (IGW) - Only provisioned if public subnets exist
# =========================================================================

resource "aws_internet_gateway" "this" {
    count = length(var.public_subnet_cidrs) > 0 ? 1: 0
    vpc_id = aws_vpc.this.id

    tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.vpc_name}-igw"
  })
  
}

# =========================================================================
# 3. NETWORK SUBNET TIERS (Public & Private)
# =========================================================================

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.vpc_name}-public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.vpc_name}-private-subnet-${count.index + 1}"
  })
}

# =========================================================================
# 4. ROUTING SYSTEMS & TABLE ASSOCIATIONS
# =========================================================================

resource "aws_route_table" "public" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.vpc_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.vpc_name}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# =========================================================================
# 5. DYNAMIC NETWORK ACCESS CONTROL LIST (NACL) FOR PUBLIC TIERS
# =========================================================================
resource "aws_network_acl" "public" {
  count  = length(var.public_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  # Anchor directly to the public SCIM ALB subnets
  subnet_ids = aws_subnet.public[*].id

  # Dynamic Inbound Traffic Perimeter Matrix Loop
  dynamic "ingress" {
    for_each = var.public_nacl_ingress_rules
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  # Dynamic Outbound Traffic Perimeter Matrix Loop
  dynamic "egress" {
    for_each = var.public_nacl_egress_rules
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = merge(var.global_tags, {
    Name = "${var.environment}-${var.vpc_name}-public-nacl"
  })
}

