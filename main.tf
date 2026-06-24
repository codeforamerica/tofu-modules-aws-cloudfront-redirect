resource "aws_cloudfront_function" "this" {
  name    = local.name
  runtime = "cloudfront-js-2.0"
  comment = "Redirect ${local.fqdn} to ${var.destination}."
  publish = true
  code = templatefile("${path.module}/templates/function.js.tftpl", {
    destination = var.destination
    static      = var.static
    status_code = var.status_code
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "this" {
  count = var.create_distribution ? 1: 0   # Skip distribution creation when attaching the function to an existing distribution.
  enabled         = true
  comment         = "Redirect ${local.fqdn} to ${var.destination}."
  is_ipv6_enabled = true
  aliases         = [var.source_domain]
  price_class     = "PriceClass_100"

  origin {
    domain_name         = var.source_domain
    origin_id           = "redirect"
    connection_attempts = 1
    connection_timeout  = 1

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${var.logging_bucket}.s3.amazonaws.com"
    prefix          = "cloudfront/${local.fqdn}"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "redirect"
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = false
    cache_policy_id        = data.aws_cloudfront_cache_policy.endpoint[0].id  # Data source is count-based, so [0] index is required.

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.this.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.this[0].arn   # Certificate is count-based, so [0] index is required.
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags

  # Cross-variable validation isn't supported in OpenTofu, so enforce
  # logging_bucket at plan time via a precondition instead.

  lifecycle {
    precondition {
      condition     = var.logging_bucket != null
      error_message = "logging_bucket is required when create_distribution is true."
    }
  }
}

resource "aws_acm_certificate" "this" {
  count = var.create_distribution ? 1 : 0   # Certificate is only needed when this module manages the distribution
  domain_name       = var.source_domain
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this" {
  for_each = var.create_distribution && var.create_records ? toset(["A", "AAAA"]) : toset([])  # DNS records only apply when this module owns the distribution.

  zone_id = data.aws_route53_zone.source["this"].zone_id
  name    = local.fqdn
  type    = each.value

  alias {
    # CloudFront doesn't provide a health check.
    evaluate_target_health = false
    # Distribution is count-based, so [0] index is required.
    name    = aws_cloudfront_distribution.this[0].domain_name
    zone_id = aws_cloudfront_distribution.this[0].hosted_zone_id
  }
}

resource "aws_route53_record" "validation" {
  # Validation records are only needed when this module manages the certificate.
  for_each = var.create_distribution && var.create_records ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.source["this"].zone_id
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  # Certificate validation only runs when this module creates the certificate.
  for_each = var.create_distribution && var.create_records ? toset(["this"]) : toset([])
  certificate_arn = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
