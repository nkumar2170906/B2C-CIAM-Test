output "alb_dns_name" {
  description = "The raw auto-generated public AWS DNS name of the Application Load Balancer"
  value       = aws_lb.scim.dns_name
}

output "alb_zone_id" {
  description = "The canonical route execution zone ID allocated to this ALB block by AWS"
  value       = aws_lb.scim.zone_id
}
