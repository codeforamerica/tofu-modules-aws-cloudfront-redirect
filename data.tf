data "aws_route53_zone" "source" {
  # Zone lookup is only needed when this module manages the distribution and DNS records.
  for_each = var.create_distribution && var.create_records ? toset(["this"]) : toset([])

  name = var.source_domain
}

data "aws_cloudfront_cache_policy" "endpoint" {
  # Cache policy lookup is only needed when creating the distribution.
  count = var.create_distribution ? 1 : 0
  name  = "Managed-CachingOptimized"
}
