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

# Calls the child module via your clean folder architecture path
module "b2c_ciam_test_network" {
  source               = "../../../modules/vpc"
  environment          = var.root_environment 
  vpc_name             = var.vpc_name
  vpc_cidr             = var.b2c_ciam_test_cidr
  public_subnet_cidrs  = var.b2c_ciam_test_public_subnet_cidrs  # For SCIM ALB (Public)
  private_subnet_cidrs = var.b2c_ciam_test_private_subnet_cidrs # For NLBs and EC2 Compute Tiers
  availability_zones   = var.aws_availability_zones
  global_tags          = var.tags

  # INTERCEPT AND PASS DOWN THE DYNAMIC NACL PERIMETER ENTRIES:
  public_nacl_ingress_rules = var.root_public_nacl_ingress
  public_nacl_egress_rules  = var.root_public_nacl_egress

}

# Asynchronous Multi-Account Router Attachment Block

/*
module "cross_account_router" {
  source                       = "../../../modules/transit_gateway"
  environment                  = var.root_environment
  global_tags                  = var.tags

  # Clean internal dependencies feeding straight from the network module outputs

  local_vpc_id                 = module.b2c_ciam_test_network.vpc_id
  local_private_subnet_ids     = module.b2c_ciam_test_network.private_subnet_ids
  local_private_route_table_id = module.b2c_ciam_test_network.private_route_table_id
  tg_id                         = var.root_existing_tgw_id
  tgw_destination_cidr_block    = var.root_tgw_destination_cidr_block

}*/

/*
  # Cross-Account Parameter Mappings (Fed securely from your tfvars)
  external_vpc_cidr       = var.external_ciam_vpc_cidr
  external_aws_account_id = var.external_aws_account_id
  tg_id                   = var.root_existing_tgw_id
*/
/*
module "cross_account_router" {
    source  =   "../../modules/transit_gateway"
    environment = var.root_environment
    global_tags = var.tags
    local_vpc_id = module.b2c_ciam_test_network.vpc_id
    local_private_subnet_ids = [module.b2c_ciam_test_network.private_subnet_ids]
    local_private_route_table_ids = [module.b2c_ciam_test_network.private_route_table_id]
    tg_id = var.root_existing_tgw_id
    tgw_destination_cidr_block = var.root_tgw_destination_cidr_block

}*/



# 3.Centralized Identity Namespace Management Block
module "dns_routing" {
  source               = "../../../modules/route53"
  environment          = var.root_environment
  global_tags          = var.tags
  
  # Connects directly to the live outputs of your network infrastructure
  local_vpc_id         = module.b2c_ciam_test_network.vpc_id
  
  # Parameter Mappings (Fed cleanly down from your centralized tfvars file)
  public_domain_name   = var.root_public_domain_name
  #private_domain_names  = var.rhds_private_domain_name
  external_vpc_id      = var.external_vpc_id # The target CIAM VPC ID passed from your variable.
  private_domain_names = var.root_private_domains
}