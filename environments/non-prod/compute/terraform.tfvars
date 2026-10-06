#===================================================================
#VARIABLE DEFINETION FOR EC2 INSTANCES
#====================================================================

root_environment  = "non-prod"
aws_region        = "eu-central-1"
golden_ami_id     = "ami-0123456789abcdef0"
key_name          = "my-test-keypair"

external_vpc_cidr                 = "172.16.0.0/16" 
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
    instance_type          = "m6i.xlarge"
    volume_size            = 100
    role                   = "master"
    allocate_secondary_eni = true  # True -> Keeps eth1 active for your SCIM Gateway
  },
  "ec2-slave-1" = {
    instance_type          = "m6i.large"
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


