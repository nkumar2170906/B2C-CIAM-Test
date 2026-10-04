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
