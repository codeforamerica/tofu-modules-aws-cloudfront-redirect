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