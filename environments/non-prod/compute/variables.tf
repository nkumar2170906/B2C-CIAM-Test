# =========================================================================
# CENTRAL ROOT MODULE VARIABLE DECLARATIONS FOR COMPUTE LAYER
# =========================================================================

variable "aws_region" {
  type        = string
  description = "The target AWS geographic deployment region"
  default     = "eu-central-1"
}

variable "root_environment" {
  type        = string
  description = "Operational stage environment namespace flag (e.g., non-prod)"
}

variable "golden_ami_id" {
  type        = string
  description = "The security-hardened golden image ID approved for private instance deployment"
}

variable "key_name" {
  type        = string
  description = "The pre-registered AWS Key Pair name for fallback authentication access"
  default     = null
}

variable "external_vpc_cidr" {
  type        = string
  description = "The absolute IP CIDR block allocation of the incoming Frankfurt CIAM VPC (e.g., 172.16.0.0/16)"
}

variable "b2c_ciam_test_public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDR list used to restrict instance traffic boundaries at the firewall perimeter"
}

variable "b2c_ciam_directory_nodes" {
  type = map(object({
    instance_type          = string
    volume_size            = number
    role                   = string
    allocate_secondary_eni = bool # True keeps eth1 active for your SCIM Gateway, all EIP allocations stripped!
  }))
  description = "Detailed configuration matrix grid for true private compute cluster nodes"
}

variable "tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}

# Inside environments/non-prod/2-compute/variables.tf

variable "app_inbound_firewall_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Dynamic array mapping for instance security group firewall entry matrices"
}


/*
variable "scim_ssl_certificate_arn" {
  type        = string
  description = "The corporate ACM certificate ARN used to secure public SCIM API endpoints"
}*/
