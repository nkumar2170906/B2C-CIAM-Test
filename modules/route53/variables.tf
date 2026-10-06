variable "public_domain_name" {
  type        = string
  description = "The registered top-level domain name for internet facing services (e.g., clientcompany.com)"
}

variable "private_domain_names" {
  type        = map(string)
  description = "A mapping container holding all target internal private domains"
}

variable "local_vpc_id" {
  type        = string
  description = "The local RHDS VPC ID that hosts this Private Hosted Zone configuration"
}

variable "external_vpc_id" {
  type        = string
  description = "The structural VPC ID string belonging to the independent CIAM team's account"
}

variable "external_vpc_region" {
  type = string
  description = "Resource block tells AWS exactly which geographic data center region your incoming VPC lives in"
  
}

variable "environment" {
  type        = string
  description = "Namespace operational context flag (e.g., non-prod or prod)"
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata tags"
  default     = {}
}
