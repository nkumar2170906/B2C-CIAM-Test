
#================================================================
# VARIABLES DEFINITION FOR VPC CHILD MODULE
#===============================================================


variable "vpc_cidr" {
    type = string
    description = "The primary IP range allocation block for the VPC"
  
}

variable "vpc_name" {
    type = string
    description = "A naming identifier suffix for network labeling (e.g., rhds or ciam)"
  
}

variable "private_subnet_cidrs" {
    type = list(string)
    description = "A list of IP subnet blocks designated for secure private boundaries"
    default = []
}

variable "public_subnet_cidrs" {
    type = list(string)
    description = "A list of IP subnet blocks designated for public boundaries" 
    default = []
}

variable "availability_zones" {
    type = list(string)
    description = "Target AWS Availability Zones to map out the network infrastructure across"
}

variable "environment" {
  type        = string
  description = "Deployment environment namespace flag (e.g., non-prod or prod)"
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}
#================================
##NACLE variables

variable "public_nacl_ingress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = number
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  description = "Matrix list of allowed inbound network ACL parameters"
  default     = []
}

variable "public_nacl_egress_rules" {
  type = list(object({
    protocol   = string
    rule_no    = number
    action     = string
    cidr_block = string
    from_port  = number
    to_port    = number
  }))
  description = "Matrix list of allowed outbound network ACL parameters"
  default     = []
}
####################################################



