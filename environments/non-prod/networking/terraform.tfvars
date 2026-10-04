aws_region             = "eu-central-1"
environment            = "non-prod"
aws_availability_zones = ["eu-central-1a", "eu-central-1b"]
vpc_name                = "b2c_ciam_test"

# Explicit Non-Prod IP Allocations matching your architecture model
b2c_ciam_test_cidr                 = ["10.200.0.0/16"]
b2c_ciam_test_public_subnet_cidrs  = ["10.200.1.0/24"]  # SCIM Public Subnet tier
b2c_ciam_test_private_subnet_cidrs = ["10.200.2.0/24", "10.200.10.0/24"] # NLB Subnet (2.0) and AZ1 Compute Tier (10.0)

# =========================================================================
# CROSS-ACCOUNT METADATA (Collected from external teams via prerequisites)
# =========================================================================
exteral_vpc_cidr       =  ["172.31.0.0/16"] # The external CIAM VPC address bounds
external_aws_account_id = ["039714564399"]  # The 12-digit AWS Account identifier for CIAM team


# =========================================================================
# DOMAIN IDENTITY & CROSS-ACCOUNT DNS HANDSHAKE METADATA 
# =========================================================================
public_domain_name  = "test.com"          # The pre-owned public root domain
private_domain_name = "internal.test.com" # The enterprise private zone domain standard
external_vpc_id     = "vpc-038b4d7cf77b5248b"      # The independent CIAM team's actual VPC ID


tags = {
  Project     = "B2C-CIAM-Identity-Platform"
  ManagedBy   = "Terraform-GitOps"
  Architecture = "Tiered-Secure-DirectoryServices"
}
