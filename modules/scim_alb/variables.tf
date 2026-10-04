variable "environment" {
  type        = string
  description = "The target stage operational namespace context flag (e.g., non-prod or prod)"
}

variable "vpc_id" {
  type        = string
  description = "The structural network VPC ID identifier holding the ALB components"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs allocated to bind the ALB to the Internet Gateway"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group firewall container IDs to mount on the ALB"
}

variable "master_instance_id" {
  type        = string
  description = "The target EC2 instance identifier hosting the primary SCIM application stack"
}

variable "backend_app_port" {
  type        = number
  description = "The internal application socket port processing the SCIM API engine payloads"
  default     = 8080
}

variable "health_check_path" {
  type        = string
  description = "The endpoint URI URL route targeted for service viability monitoring checks"
  default     = "/health"
}

variable "global_tags" {
  type        = map(string)
  description = "Standard corporate resource labeling metadata mapping"
  default     = {}
}

variable "enable_stickiness" {
  type        = bool
  description = "Toggle flag to activate or deactivate target group session affinity"
  default     = true
}

variable "cookie_duration_seconds" {
  type        = number
  description = "The lifespan window for the session cookie in seconds (e.g., 86400 for 1 day)"
  default     = 86400
}

