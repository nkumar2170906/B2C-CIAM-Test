
#================================================================
# VARIABLES DEFINITION FOR SECURITY GROUP CHILD MODULE
#===============================================================

variable "vpc_id" {
  type        = string
  description = "The target VPC ID where the security group resource will be anchored"
}

variable "sg_name" {
  type        = string
  description = "A naming identifier suffix for security group labeling (e.g., app, alb, nlb)"
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Structured list of allowed inbound firewall configuration matrices"
  default     = []
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Structured list of allowed outbound firewall configuration matrices"
  default = [
    {
      description = "Default corporate egress rule: allow all outbound internet traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "environment" {
  type        = string
  description = "Operational stage environment namespace flag (e.g., non-prod or prod)"
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}
