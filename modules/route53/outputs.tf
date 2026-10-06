/*
output "public_zone_id" {
  description = "The unique global identifier of the public hosted zone container"
  value       = data.aws_route53_zone.public.zone_id
}*/

output "public_zone_id" {
  description = "The unique global identifier of the public hosted zone container"
  value       = aws_route53_zone.public.zone_id 
}

output "private_zone_ids" {
  description = "A mapping container returning your active private hosted zone IDs"
  value       = { for k, v in aws_route53_zone.private : k => v.zone_id }
}

