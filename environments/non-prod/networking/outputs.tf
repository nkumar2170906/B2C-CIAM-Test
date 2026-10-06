# =========================================================================
# EXPORTED NETWORK LAYER 1 PLATFORM OUTPUT HOOKS
# =========================================================================

output "vpc_id" {
  description = "The dynamic AWS unique identifier for the b2c_ciam_test core network"
  value       = module.b2c_ciam_test_network.vpc_id 
}

output "private_subnet_ids" {
  description = "The list array holding both of your private subnet identifiers"
  value       = module.b2c_ciam_test_network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "The list array holding your public SCIM ALB subnet identifiers"
  value       = module.b2c_ciam_test_network.public_subnet_ids
}

output "private_route_table_id" {
  description = "The private routing table container identifier, required later for Transit Gateway routes"
  value       = module.b2c_ciam_test_network.private_route_table_id
}
