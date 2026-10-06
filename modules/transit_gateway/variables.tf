
variable "tg_id" {
    type = string
     description = "The client's pre-existing centralized Transit Gateway ID"
}

variable "local_vpc_id" {
  type        = string
  description = "The target VPC ID inside the local account where the TGW will attach"
}

variable "local_private_subnet_ids" {
  type        = list(string)
  description = "The internal subnet IDs mapping out high-availability attachment cross zones"
}

variable "global_tags" {
  type        = map(string)
  description = "Corporate cloud inventory labeling metadata tags"
  default     = {}
}

variable "environment" {
  type        = string
  description = "Namespace operational context flag (e.g., non-prod or prod)"
}

variable "local_private_route_table_ids" {
    type = list(string)
    description = "List of private route table IDs passed from the core VPC module"
}

variable "tgw_destination_cidr_block" {
  type        = string
  description = "The destination network block address to route through the centralized TGW"
}



/*

variable "local_private_route_table_id" {
  type        = string
  description = "The private route table container ID where the cross-VPC route rule will be inserted"
}

/*
variable "external_vpc_cidr" {
  type        = string
  description = "The absolute IP CIDR block allocation of the independent CIAM VPC (e.g., 10.100.0.0/16)"
}*/

/*
variable "external_aws_account_id" {
  type        = string
  description = "The 12-digit structural AWS Account ID hosting the external CIAM environment"
}









variable "tgw_destination_cidr_block" {
  type        = string
  description = "The destination network block address to route through the centralized TGW"
}


variable "existing_transit_gateway_id" {
  type        = string
  description = "The target AWS ID string of the client's existing centralized TGW (e.g., tgw-0123456789abcdef0)"
}*/
