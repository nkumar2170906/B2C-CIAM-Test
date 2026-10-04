output "public_zone_id" {
  description = "The unique global identifier of the public hosted zone container"
  value       = data.aws_route53_zone.public.zone_id
}

output "private_zone_id" {
  description = "The unique network identifier of your internal private hosted zone"
  value       = aws_route53_zone.private.id
}
