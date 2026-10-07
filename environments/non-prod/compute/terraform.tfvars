

#===================================================================
#VARIABLE DEFINETION FOR EC2 INSTANCES
#====================================================================

root_environment  = "non-prod"
aws_region        = "eu-central-1"
golden_ami_id     = "ami-027198f65e9f969f8"
key_name          = null

#external_vpc_cidr                 = "172.16.0.0/16" 
b2c_ciam_test_public_subnet_cidrs = ["10.200.1.0/24"]


app_inbound_firewall_rules = [
  {
    description = "Default open baseline path requested by Client Security Architect"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

# =========================================================================
# PUBLIC GATEWAY SECURITY CERTIFICATES REFERENCE
# =========================================================================
# Replace this placeholder with your real ACM Certificate ARN from your personal AWS account console

##scim_ssl_certificate_arn = "arn:aws:acm:eu-central-1:123456789012:certificate/abcdef01-2345-6789-abcd-ef0123456789"

# =========================================================================
# EC2 INSTANCES TYPE AND STORAGE SIZE
# =========================================================================
b2c_ciam_directory_nodes = {
  "ec2-master-1" = {
    instance_type          = "t2.micro"
    volume_size            = 100
    role                   = "master"
    allocate_secondary_eni = true  # True -> Keeps eth1 active for your SCIM Gateway
  },
  "ec2-slave-1" = {
    instance_type          = "t2.micro"
    volume_size            = 50
    role                   = "slave"
    allocate_secondary_eni = false # False -> Standard clean private node
  }
}

tags = {
  Project      = "B2C-CIAM-Identity-Platform"
  ManagedBy    = "Terraform-GitOps"
  Architecture = "Tiered-Secure-DirectoryServices"
}

# Inside environments/non-prod/2-compute/terraform.tfvars

# =========================================================================
# 🛡️ SECURITY GROUP RULES INBOUND MATRIX GRID
# =========================================================================

/*
app_inbound_firewall_rules = [
  {
    description = "Rule 1: Wide-open testing path requested by Client Security Architect"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Rule 2: Restrict secure LDAPS queries to multiple cross-account subnets"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    # 🎯 MULTIPLE CIDRS: Just pass them as a clean array list!
    cidr_blocks = ["172.16.0.0/16", "10.100.0.0/16", "192.168.1.0/24"] 
  },
  {
    description = "Rule 3: Open custom web sync ports for specialized office network boundaries"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["10.200.1.0/24", "10.50.0.0/16"]
  }
]
*/

