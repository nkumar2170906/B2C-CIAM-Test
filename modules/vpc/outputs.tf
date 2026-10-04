output "vpc_id" {
  description = "The unique structural identifier of the provisioned VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of IDs of the provisioned public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the provisioned private subnets"
  value       = aws_subnet.private[*].id
}

output "private_route_table_id" {
  description = "The private routing table container identifier, required later for Transit Gateway routes"
  value       = aws_route_table.private.id
}
