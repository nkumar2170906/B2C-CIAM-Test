output "transit_gateway_id" {
  description = "The unique AWS network identifier assigned to this Transit Gateway instance"
  value       = aws_ec2_transit_gateway.this.id
}
