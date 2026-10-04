output "nlb_dns_name" {
  description = "The structural internal AWS private DNS address mapping of the Network Load Balancer"
  value       = aws_lb.consumer.dns_name
}

output "nlb_zone_id" {
  description = "The canonical route execution zone ID allocated to this Network Load Balancer by AWS"
  value       = aws_lb.consumer.zone_id
}
