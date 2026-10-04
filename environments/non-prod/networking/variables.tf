/*
variable "exteral_vpc_cidr" {
    type = string
    description = "The primary IP range allocation block for the VPC"
 }*/

/*
variable "b2c_ciam_test" {
    type = string
    description = "b2c_ciam_test"
  
}*/

variable "external_vpc_id" {
    type = string
    description = "external vpc id"
  
}

variable "vpc_name" {
    type = string
    description = "A naming identifier suffix for network labeling (e.g., rhds or ciam)"
  
}

variable "rhds_public_domain_name" {
    type = string
    description = "Public domain name"
}

variable "rhds_private_domain_name" {
    type = string
    description = "Private domain name"
  
}

variable "aws_region" {
    type = string
    description = "A naming identifier suffix for network labeling (e.g., rhds or ciam)"
  
}

variable "b2c_ciam_test_public_subnet_cidrs" {
    type = list(string)
    description = "A list of IP subnet blocks designated for secure private boundaries"
    //default = []
}

variable "external_ciam_vpc_cidr" {
    type = string
  
}

variable "b2c_ciam_test_cidr" {
    type = string
    description = "A list of IP subnet blocks designated for secure private boundaries"
    //default = []
}

variable "b2c_ciam_test_private_subnet_cidrs" {
    type = list(string)
    description = "A list of IP subnet blocks designated for secure private boundaries"
    //default = []
}
/*
variable "public_subnet_cidrs" {
    type = list(string)
    description = "A list of IP subnet blocks designated for public boundaries" 
    //default = []
}*/

variable "aws_availability_zones" {
    type = list(string)
    description = "Target AWS Availability Zones to map out the network infrastructure across"
}

variable "external_aws_account_id" {
    type = string
    description = "External client account id"
}

variable "environment" {
  type        = string
  description = "Deployment environment namespace flag (e.g., non-prod or prod)"
}

variable "tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}
