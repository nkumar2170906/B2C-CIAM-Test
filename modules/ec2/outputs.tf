output "instance_ids" {
  description = "A complete structural map containing instance keys and their respective AWS node identifiers"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "instance_private_ips" {
  description = "A mapping container holding internal network private IPs allocated across the nodes"
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}

output "instance_public_ips" {
  description = "A mapping container holding the persistent public Elastic IP addresses for authorized nodes"
  value       = { for k, v in aws_eip.this : k => v.public_ip }
}
