terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "b2c-ciam-tfstate-nonprod"
    key            = "non-prod/networking/terraform.tfstate"
    region         = "eu-central-1"
    #dynamodb_table = "b2c-ciam-tflocks-nonprod"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# =========================================================================
# 1. PRIMARY NETWORK TIERS BLOCK  - VPC
# =========================================================================
module "b2c_ciam_test_network" {
  source               = "../../../modules/vpc"
  environment          = var.root_environment 
  vpc_name             = var.vpc_name
  vpc_cidr             = var.b2c_ciam_test_vpc_cidr
  public_subnet_cidrs  = var.b2c_ciam_test_public_subnet_cidrs  # For SCIM ALB (Public)
  private_subnet_cidrs = var.b2c_ciam_test_private_subnet_cidrs # For NLBs and EC2 Compute Tiers
  availability_zones   = var.aws_availability_zones
  global_tags          = var.tags

  # INTERCEPT AND PASS DOWN THE DYNAMIC NACL PERIMETER ENTRIES:
  public_nacl_ingress_rules = var.root_public_nacl_ingress
  public_nacl_egress_rules  = var.root_public_nacl_egress

}

# ===========================================================================================
# 2. TRANSIT GATEWAY ATTACHMENT - CROSS-ACCOUNT ROUTER LINKING TO EXISTING CENTRALIZED TGW
# ==========================================================================================

module "cross_account_router" {
  source = "../../../modules/transit_gateway"
  environment = var.root_environment
  global_tags = var.tags
  local_vpc_id = module.b2c_ciam_test_network.vpc_id
  local_private_subnet_ids = module.b2c_ciam_test_network.private_subnet_ids
  local_private_route_table_ids = [module.b2c_ciam_test_network.private_route_table_id]
  tg_id = var.root_existing_tgw_id
  tgw_destination_cidr_block = var.root_tgw_destination_cidr_block

}

# =========================================================
#   3. ROUTE-53 BLOCK
# ===========================================================

module "dns_routing" {
  source               = "../../../modules/route53"
  environment          = var.root_environment
  global_tags          = var.tags
  local_vpc_id         = module.b2c_ciam_test_network.vpc_id
  public_domain_name   = var.root_public_domain_name
  private_domain_names = var.root_private_domains
  external_vpc_id      = var.external_ciam_vpc_id # The target CIAM VPC ID passed from your variable.
  external_vpc_region = var.external_ciam_vpc_region
}