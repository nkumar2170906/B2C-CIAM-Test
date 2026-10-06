output "alb_arn" {
  description = "The unique Amazon Resource Name matching the SCIM ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "The public, internet-facing DNS endpoint matching your SCIM ALB"
  value       = aws_lb.this.dns_name
}
