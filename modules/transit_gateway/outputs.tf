
output "transit_gateway_attachment_id" {
  description = "The unique AWS identifier of your local VPC attachment to provide to the client team"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}
