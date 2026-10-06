output "instance_ids" {
  description = "A clean mapping matrix linking instance configuration keys to their dynamic AWS resource IDs"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "instance_private_ips" {
  description = "The internal private IP addresses allocated dynamically across the private network interface nodes"
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}

output "secondary_network_interface_ids" {
  description = "The raw identifiers of the secondary network interfaces (eth1) generated for authorized nodes"
  value       = { for k, v in aws_network_interface.secondary : k => v.id }
}
