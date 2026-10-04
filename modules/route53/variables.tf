variable "public_domain_name" {
  type        = string
  description = "The registered top-level domain name for internet facing services (e.g., clientcompany.com)"
}

variable "private_domain_name" {
  type        = string
  description = "The custom private internal naming namespace (e.g., internal.clientcompany.com)"
}

variable "local_vpc_id" {
  type        = string
  description = "The local RHDS VPC ID that hosts this Private Hosted Zone configuration"
}

variable "external_vpc_id" {
  type        = string
  description = "The structural VPC ID string belonging to the independent CIAM team's account"
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
