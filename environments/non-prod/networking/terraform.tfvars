aws_region                        = "eu-central-1"
root_environment                  = "non-prod"
aws_availability_zones            = ["eu-central-1a", "eu-central-1b"]
vpc_name                          = "b2c_ciam_test"
root_existing_tgw_id              = "tgw-0556fec8e90da7112"
root_tgw_destination_cidr_block   = "10.0.0.0/8"
external_ciam_vpc_id              = "vpc-0d2ce2dd7a202c249"
external_ciam_vpc_region          = "eu-central-1" 
#external_aws_account_id          = "039714564399"  # The 12-digit AWS Account identifier for CIAM team


# Explicit Non-Prod IP Allocations matching your architecture model
b2c_ciam_test_vpc_cidr             = "10.200.0.0/16"
b2c_ciam_test_public_subnet_cidrs  = ["10.200.1.0/24"]  # SCIM Public Subnet tier
b2c_ciam_test_private_subnet_cidrs = ["10.200.2.0/24", "10.200.10.0/24"] # NLB Subnet (2.0) and AZ1 Compute Tier (10.0)


# =========================================================================
# DOMAIN IDENTITY & CROSS-ACCOUNT DNS HANDSHAKE METADATA 
# =========================================================================
root_public_domain_name             = "nkumartest.com"          # The pre-owned public root domain
#rhds_private_domain_name           = "master.nkumartest.com" # The enterprise private zone domain standard
root_private_domains = {
  "primary-internal"   = "master.nkumartest.com"      # Zone #1 (Original)
  "secondary-internal" = "consumer.nkumartest.com" # Zone #2 (NEW Private Zone!)
}



# =========================================================================
# DYNAMIC PERIMETER SECURITY RULES FOR PUBLIC ALB TIERS
# =========================================================================
root_public_nacl_ingress = [
  {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Allow internet users to access HTTPS web layer
    from_port  = 443
    to_port    = 443
  },
  {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Allow internet users to access HTTP for redirects
    from_port  = 80
    to_port    = 80
  },

  {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0" # Open Ephemeral return bounds
    from_port  = 1024
    to_port    = 65535
  }
]

root_public_nacl_egress = [
  {
    protocol   = "-1" # Stateless return path: allow all outbound response traffic
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
]

tags = {
  Project     = "B2C-CIAM-Identity-Platform"
  ManagedBy   = "Terraform-GitOps"
  Architecture = "Tiered-Secure-DirectoryServices"
}
