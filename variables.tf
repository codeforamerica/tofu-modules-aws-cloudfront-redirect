variable "create_records" {
  type        = bool
  description = <<-EOT
    Create DNS records using Route 53. A hosted zone matching the source domain
    must exist. If `false`, the certificate must be manually validated. Only
    applies when `create_distribution` is `true`.
    EOT
  default     = true
}

variable "destination" {
  type        = string
  description = <<-EOT
    Destination for redirects, including scheme (e.g. https://my.domain.com).
    EOT
}

variable "forward_query" {
  type        = bool
  description = <<-EOT
    Forward the incoming request's query string to the destination. When the
    destination already contains query parameters, the incoming parameters are
    appended (incoming keys can collide with destination keys; browsers will
    typically honor the last occurrence).
    EOT
  default     = true
}

variable "logging_bucket" {
  description = "The S3 bucket used for logging. Required when `create_distribution` is `true`."
  type        = string
  default     = null

  # OpenTofu supports cross-variable validation; enforce logging_bucket
  # is required when create_distribution is true.
  validation {
    condition     = !var.create_distribution || var.logging_bucket != null
    error_message = "logging_bucket is required when create_distribution is true."
  }
}

variable "source_domain" {
  type        = string
  description = <<-EOT
    Domain to redirect from. This should match the hosted zone when creating
    verification records.
    EOT
}

variable "source_subdomain" {
  type        = string
  description = <<-EOT
    Optional subdomain for the source redirect. Required if the fully qualified
    domain name (FQDN) is a subdomain of the hosted zone domain.
    EOT
  default     = null
}

variable "path" {
  type        = string
  description = <<-EOT
    Optional path to match for the redirect. When set, only requests where the
    URI starts with this path are redirected. When `null`, all requests are
    redirected.
    EOT
  default     = null
}

variable "static" {
  type        = bool
  description = "Redirect to the destination without passing the path."
  default     = false
}

variable "status_code" {
  type        = number
  description = <<-EOT
    HTTP status code for the redirect. Must be either 301 (permanent) or 302
    (temporary).
    EOT
  default     = 301

  validation {
    condition     = contains([301, 302], var.status_code)
    error_message = "Status code must be either 301 or 302."
  }
}

variable "track_referrer" {
  type        = bool
  description = <<-EOT
    Capture the incoming `Referer` header and forward it to the destination as
    a `ref` query parameter. Useful for attributing traffic that arrived at the
    redirect domain via a link from an upstream site — that information is
    otherwise lost across the 301/302 hop, because the browser's `Referer` on
    the final request reflects the redirect domain rather than the upstream
    source.

    If the incoming query already contains `ref`, the incoming value is
    preserved and the `Referer` header is not captured.
    EOT
  default     = false

  validation {
    condition     = !var.track_referrer || var.status_code != 301
    error_message = "track_referrer with status_code=301 will only capture attribution on the first visit per browser, since 301s are aggressively cached. Use status_code=302."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "create_distribution" {
  type        = bool
  description = <<-EOT
    Create a new CloudFront distribution. Set to `false` to only create the
    redirect function and attach it to an existing distribution via the
    `function_arn` output.
    EOT
  default     = true
}