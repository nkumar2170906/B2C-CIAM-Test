variable "environment" {
  type        = string
  description = "The target stage operational namespace context flag (e.g., non-prod or prod)"
}

variable "vpc_id" {
  type        = string
  description = "The structural network VPC ID identifier holding the NLB components"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where the internal NLB endpoints will load balancers across"
}

variable "master_instance_id" {
  type        = string
  description = "The unique structural instance identifier representing your primary Master EC2 node"
}

variable "enable_session_stickiness" {
  type        = bool
  description = "Toggle parameter to activate or deactivate Layer 4 Source IP session persistence rules"
  default     = true
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}
