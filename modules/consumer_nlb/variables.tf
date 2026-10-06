#================================================================
# VARIABLES DEFINITION FOR CONSUMER LOAD BALANCER CHILD MODULE
#===============================================================

variable "environment" {
  type        = string
  description = "Operational stage environment namespace flag"
}

variable "vpc_id" {
  type        = string
  description = "The target core VPC identifier hosting the infrastructure"
}

variable "subnet_id" {
  type        = string
  description = "The target private subnet ID where the NLB endpoints will reside"
}

variable "slave_instance_id" {
  type        = string
  description = "The generated live AWS resource ID of the Slave/Consumer compute node"
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}
