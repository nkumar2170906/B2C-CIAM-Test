

output "nlb_arn" {
  description = "The unique Amazon Resource Name matching the Consumer NLB"
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "The private, internal DNS name allocated natively to the Consumer NLB"
  value       = aws_lb.this.dns_name
}
