output "security_group_id" {
  description = "The unique structural AWS identifier assigned to this security group"
  value       = aws_security_group.this.id
}
