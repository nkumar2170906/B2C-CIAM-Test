variable "local_vpc_id" {
  type        = string
  description = "The target VPC ID inside the local account where the TGW will attach"
}

variable "local_private_subnet_ids" {
  type        = list(string)
  description = "The internal subnet IDs mapping out high-availability attachment cross zones"
}

variable "local_private_route_table_id" {
  type        = string
  description = "The private route table container ID where the cross-VPC route rule will be inserted"
}

variable "external_vpc_cidr" {
  type        = string
  description = "The absolute IP CIDR block allocation of the independent CIAM VPC (e.g., 10.100.0.0/16)"
}

variable "external_aws_account_id" {
  type        = string
  description = "The 12-digit structural AWS Account ID hosting the external CIAM environment"
}

variable "environment" {
  type        = string
  description = "Namespace operational context flag (e.g., non-prod or prod)"
}

variable "global_tags" {
  type        = map(string)
  description = "Corporate cloud inventory labeling metadata tags"
  default     = {}
}
