output "certificate_validation_records" {
  description = "The DNS records required to validate the ACM certificate. Only populated when `create_distribution` is `true`."
  # Returns null when not managing the distribution, as there is no certificate to validate.
  value = var.create_distribution ? {
    for dvo in aws_acm_certificate.this["this"].domain_validation_options :
    dvo.resource_record_name => dvo.resource_record_value
  } : null
}

output "cloudfront_dns" {
  description = <<-EOT
    DNS information for the CloudFront distribution needed to create DNS
    records. Only populated when `create_distribution` is `true`.
    EOT
  # Returns null when not managing the distribution.
  value = var.create_distribution ? {
    name : local.fqdn
    target : aws_cloudfront_distribution.this["this"].domain_name
    zone_id : aws_cloudfront_distribution.this["this"].hosted_zone_id
  } : null
}

output "function_arn" {
  description = "The ARN of the CloudFront redirect function."
  value       = aws_cloudfront_function.this.arn
}

output "url" {
  description = "The fully qualified URL for the redirect."
  value       = local.fqdn
}
