aws_region  = "eu-central-1"
environment = "non-prod"
golden_ami_id = "ami-0123456789abcdef0" # Replace with your approved RHEL/Golden AMI ID from admin

# Target port configuration for the identity sync app
scim_application_port = 8080

# Controls Layer 4 Source IP stickiness for LDAPS connections
enable_nlb_stickiness = true


/*
# Inbound Ports mapped
app_inbound_firewall_rules = [
  {
    description = "Allow secure HTTPS traffic from the public internet for SCIM APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow secure LDAPS queries from the CIAM cross-account network space"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  },
  {
    description = "Allow standard LDAP traffic for internal network directory lookups"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }
]
*/
# =========================================================================
# COMPUTE TIERS ORCHESTRATION GRID (PRODUCATION SCALABLE)
# =========================================================================
# This map matches your architectural model layout exactly!
rhds_directory_nodes = {
  "ec2-master-1" = {
    instance_type = "m6i.xlarge"
    volume_size   = 100
    role          = "master"
    allocate_eip  = true  # Triggers the persistent static allocation for SCIM/Master footprints
  },
  "ec2-slave-1" = {
    instance_type = "m6i.large"
    volume_size   = 50
    role          = "slave"
    allocate_eip  = true  # Triggers the persistent static allocation for Consumer footprint
  }
}

tags = {
  Project      = "B2C-CIAM-Identity-Platform"
  ManagedBy    = "Terraform-GitOps"
  Architecture = "Tiered-Secure-DirectoryServices"
}
