terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "b2c-ciam-tfstate-nonprod"
    key            = "non-prod/compute/terraform.tfstate"
    region         = "eu-central-1"
    #dynamodb_table = "b2c-ciam-tflocks-nonprod"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Fetch live network parameters from Layer 1 state caching
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "client-b2c-ciam-tfstate-nonprod"
    key    = "non-prod/networking/terraform.tfstate"
    region = var.aws_region
  }
}

# =========================================================================
# 1. DEDICATED PERIMETER SECURITY GROUP FOR PUBLIC SCIM ALB
# =========================================================================
module "scim_alb_firewall" {
  source      = "../../../modules/security_group"
  environment = var.environment
  sg_name     = "scim-alb-public"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  global_tags = var.tags

  # Strictly limited to web integration traffic patterns only!
  ingress_rules = [
    {
      description = "Allow public HTTPS inbound sync requests"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
        description = "Allow public HTTP inbound requests for secure redirection"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
##############################################

# 2. CORE COMPUTE TIERS SECURITY GROUP (RHDS INSTANCES & INTERNAL NLBs)

module "compute_firewall" {
  source        = "../../../modules/security_group"
  environment   = var.environment
  sg_name       = "directory-services"
  vpc_id        = data.terraform_remote_state.networking.outputs.vpc_id
  ingress_rules = var.app_inbound_firewall_rules
  global_tags   = var.tags
}

# 3.Dynamic High-Availability Directory Services Compute Tier
module "rhds_cluster" {
  source             = "../../../modules/ec2"
  environment        = var.environment
  global_tags        = var.tags
  
  # Inject the golden AMI and secure identifiers dynamically from outputs
  ami_id             = var.golden_ami_id
  security_group_ids = [module.compute_firewall.security_group_id]
  
  # Automatically drops the instances into the private AZ1 compute subnet tier created in Layer 1
  subnet_id          = data.terraform_remote_state.networking.outputs.private_subnet_ids[1] # Maps index 1 (10.200.10.0/24)
  
  # Feeds the structural cluster metadata configuration cleanly from your tfvars
  cluster_nodes      = var.rhds_directory_nodes
}

# 4. Standalone Internet-Facing Identity Integration Gateway Layer
module "public_scim_gateway" {
  source             = "../../../modules/scim_alb"
  environment        = var.environment
  global_tags        = var.tags

  # Catching live network outputs dynamically from Layer 1 remote state caching
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.networking.outputs.public_subnet_ids

  # Wire up the security perimeter and target node bindings cleanly
  security_group_ids = [module.scim_alb_firewall.security_group_id]
  
  # Extracts the exact Master instance token dynamically out of your cluster map
  master_instance_id = module.rhds_cluster.instance_ids["ec2-master-1"]

  # App configs passed from the variables definitions
  backend_app_port   = var.scim_application_port
  health_check_path  = "/scim/v2/health"
}

# 5.Standalone Private Master Network Load Balancer (Secure Writes)
module "private_master_lb" {
  source                    = "../../../modules/master_nlb"
  environment               = var.environment
  global_tags               = var.tags

  # Fetch network parameters dynamically from Layer 1 remote state caching
  vpc_id                    = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids

  # Extracts the exact Master instance ID token dynamically out of your cluster map
  master_instance_id        = module.rhds_cluster.instance_ids["ec2-master-1"]

  # Binds session rules dynamically from your centralized configuration handles
  enable_session_stickiness = var.enable_nlb_stickiness
}

# Standalone Private Consumer Network Load Balancer (Secure Reads/Queries)
module "private_consumer_lb" {
  source                    = "../../../modules/consumer_nlb"
  environment               = var.environment
  global_tags               = var.tags

  # Fetch network parameters dynamically from Layer 1 remote state caching
  vpc_id                    = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids        = data.terraform_remote_state.networking.outputs.private_subnet_ids

  # Extracts the exact Slave instance ID token dynamically out of your cluster map
  slave_instance_id         = module.rhds_cluster.instance_ids["ec2-slave-1"]

  # Binds session rules dynamically from your centralized configuration handles
  enable_session_stickiness = var.enable_nlb_stickiness
}


