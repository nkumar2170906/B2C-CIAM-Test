
#================================================================
# VARIABLES DEFINITION FOR EC2 INSTANCE CHILD MODULE
#===============================================================


variable "environment" {
  type        = string
  description = "Operational stage environment namespace flag (e.g., non-prod or prod)"
}

variable "ami_id" {
  type        = string
  description = "The target security-hardened golden image ID approved for deployment"
}

variable "subnet_id" {
  type        = string
  description = "The target private subnet ID where the cluster instances will reside"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of firewall security group IDs to mount onto the cluster nodes"
}

variable "key_name" {
  type        = string
  description = "The pre-registered AWS Key Pair name for emergency fallback authentication access"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}

variable "cluster_nodes" {
  type = map(object({
    instance_type          = string
    volume_size            = number
    role                   = string
    allocate_secondary_eni = bool # Keeps the dual-interface requirement active for Master
  }))
  description = "Detailed mapping grid containing specific structural allocations for individual compute nodes"
}

