# =========================================================================
# CENTRAL ROOT MODULE VARIABLE DECLARATIONS FOR COMPUTE LAYER
# =========================================================================

variable "aws_region" {
  type        = string
  description = "The target AWS deployment region for compute services (e.g., eu-central-1)"
}

variable "environment" {
  type        = string
  description = "The deployment stage environment identifier (e.g., non-prod)"
}

variable "golden_ami_id" {
  type        = string
  description = "The target security-hardened golden image ID approved for deployment"
}

variable "app_inbound_firewall_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Structured list of approved inbound firewall configuration matrices"
  default     = []
}

variable "rhds_directory_nodes" {
  type = map(object({
    instance_type = string
    volume_size   = number
    role          = string
    allocate_eip  = bool
  }))
  description = "Detailed mapping layout containing parameters for individual compute nodes"
}

variable "tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata tags"
  default     = {}
}

variable "scim_application_port" {
  type        = number
  description = "The internal target port for the SCIM gateway application node"
}

variable "enable_nlb_stickiness" {
  type        = bool
  description = "Toggle parameter to handle session affinity across the directory services layer"
}
