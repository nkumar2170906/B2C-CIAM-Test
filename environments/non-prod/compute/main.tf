terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket         = "b2c-ciam-tfstate-nonprod"
    key            = "non-prod/compute/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Fetch live network parameters from Layer 1 state caching.
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "b2c-ciam-tfstate-nonprod"
    key    = "non-prod/networking/terraform.tfstate"
    region = "eu-central-1"
  }
}

# =========================================================================
# EC2 CLUSTER TIERS DEPLOYMENT
# =========================================================================
module "b2c_ciam_cluster" {
  source             = "../../../modules/ec2" # Aligned strictly to your verified 3-dot path configuration
  environment        = var.root_environment
  global_tags        = var.tags
  ami_id             = var.golden_ami_id
  key_name           = var.key_name
  
  # Connects directly to the private firewall security group ID
  security_group_ids = [module.compute_firewall.security_group_id]
  
  # Automatically grabs Private Subnet 1 (10.186.24.96/27) out of your live Layer 1 network outputs array
  subnet_id          = data.terraform_remote_state.networking.outputs.private_subnet_ids[1]
  
  # Feeds your updated matrix definition matrix cleanly down to the child loop
  cluster_nodes      = var.b2c_ciam_directory_nodes

  # DEPENDENCY GATEWAY: The cluster will NOT start creating unless the firewall is fully live!
  depends_on = [
    module.compute_firewall
  ]
}

# =========================================================================
# PRIVATE MASTER(PRIVATE) NETWORKING LOAD BALANCER
# =========================================================================
module "master_nlb" {
  source             = "../../../modules/master_nlb" # Aligned perfectly with your triple-dot layout
  environment        = var.root_environment
  global_tags        = var.tags
  
  # Extracts the core network properties dynamically from the live Layer 1 state S3 bucket
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  
  # Automatically places the NLB interface into Private Subnet 0 (Index 0: 10.186.24.64/27)
  subnet_id          = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  
  # Passes down the newly built dynamic instance target directly from your compute output grid mappings
  master_instance_id = module.b2c_ciam_cluster.instance_ids["ec2-master-1"]

  # DEPENDENCY GATEWAY: Prevents the NLB from building until the backend instance exists!
  depends_on = [
    module.b2c_ciam_cluster
  ]
}

# =========================================================================
# PRIVATE CONSUMER NETWORKING LOAD BALANCER
# =========================================================================
module "consumer_nlb" {
  source             = "../../../modules/consumer_nlb" # Aligned perfectly with your triple-dot layout
  environment        = var.root_environment
  global_tags        = var.tags
  
  # Extracts the core network properties dynamically from the live Layer 1 state S3 bucket
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  
  # Automatically places the NLB interface into Private Subnet 0 (Index 0: 10.186.24.64/27)
  subnet_id          = data.terraform_remote_state.networking.outputs.private_subnet_ids
  
  # Passes down the newly built dynamic slave instance target directly from your compute output grid mappings
  slave_instance_id  = module.b2c_ciam_cluster.instance_ids["ec2-slave-1"]

  # DEPENDENCY GATEWAY: Prevents the NLB from building until the backend instance exists!
  depends_on = [
    module.b2c_ciam_cluster
  ]
}

# =========================================================================
# PUBLIC INTERNET-FACING SCIM GATEWAY  (ALB LAYER)
# =========================================================================
module "public_scim_gateway" {
  source             = "../../../modules/scim_alb" # Aligned perfectly with your triple-dot layout
  environment        = var.root_environment
  global_tags        = var.tags
  
  # Extracts the core network properties dynamically from the live Layer 1 state S3 bucket
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.networking.outputs.public_subnet_ids
  
  # Connects directly to the dedicated public web firewall group instead of the compute group
  security_group_ids = [module.scim_alb_firewall.security_group_id]
  
  # Passes down the newly built dynamic instance target directly from your compute output grid mappings
  master_instance_id = module.b2c_ciam_cluster.instance_ids["ec2-master-1"]
  
  backend_port        = 8443
  ##acm_certificate_arn = var.scim_ssl_certificate_arn

 # DEPENDENCY GATEWAY: Ensures the ALB target group doesn't link to a ghost instance!
  depends_on = [
    module.b2c_ciam_cluster,
    module.scim_alb_firewall
  ]

}

# =========================================================================
# 1. DECOUPLED PERIMETER SECURITY GROUPS
# =========================================================================

# Strict Public Internet Firewall for the SCIM ALB
module "scim_alb_firewall" {
  source      = "../../../modules/security_group"
  environment = var.root_environment
  sg_name     = "b2c-ciam-scim-alb-public"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  global_tags = var.tags

  ingress_rules = [
    { 
      description = "Allow public inbound sync traffic from DAWN / Internet on Port 80 for testing" 
      from_port   = 0      #80 
      to_port     = 65535  #80 
      protocol    = "tcp" 
      cidr_blocks = ["0.0.0.0/0"] 
    }
  ]
}

# Secure Private Firewall protecting your Cluster Instances (Airtight Data Tier)
module "compute_firewall" {
  source      = "../../../modules/security_group"
  environment = var.root_environment
  sg_name     = "b2c-ciam-instance-firewall"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  global_tags = var.tags

  ingress_rules = [
    {
      description = "Rule 1: Allow secure LDAPS queries from the CIAM EKS Subnet range"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      cidr_blocks = [var.external_vpc_cidr] # Securely hooks to your friend's 172.16.0.0/16 range
    },
    {
      description = "Rule 2: Allow incoming SCIM sync traffic strictly from the SCIM ALB subnet range"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      cidr_blocks = var.b2c_ciam_test_public_subnet_cidrs # Locks 8443 down to your public subnet boundaries
    }
  ]
}

