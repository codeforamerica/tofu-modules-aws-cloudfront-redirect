# Resources changed from singleton to count-based to support optional
# distribution creation. These moved blocks prevent recreation for existing
# users of the module who have create_distribution = true (the default).

moved {
  from = aws_cloudfront_distribution.this
  to   = aws_cloudfront_distribution.this["this"]
}

moved {
  from = aws_acm_certificate.this
  to   = aws_acm_certificate.this["this"]
}

moved {
  from = data.aws_cloudfront_cache_policy.endpoint
  to   = data.aws_cloudfront_cache_policy.endpoint["this"]
}
