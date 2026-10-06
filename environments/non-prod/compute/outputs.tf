# =========================================================================
# ROOT COMPUTE MODULE CORE METRICS OUTPUTS
# =========================================================================

output "deployed_instance_ids" {
  description = "The generated live AWS instance identifiers for your cluster nodes"
  value       = module.b2c_ciam_cluster.instance_ids
}

output "deployed_private_ips" {
  description = "The secure internal private IP maps allocated to your directory cluster"
  value       = module.b2c_ciam_cluster.instance_private_ips
}

output "master_nlb_private_dns" {
  description = "The private internal network lookup address matching your Master directory NLB"
  value       = module.master_nlb.nlb_dns_name
}

output "consumer_nlb_private_dns" {
  description = "The private internal network lookup address matching your Consumer directory NLB"
  value       = module.consumer_nlb.nlb_dns_name
}

output "public_scim_gateway_dns" {
  description = "The internet-facing endpoint address matching your public SCIM ALB"
  value       = module.public_scim_gateway.alb_dns_name
}
