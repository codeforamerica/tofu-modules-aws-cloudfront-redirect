# AWS CloudFront Redirect Module

[![GitHub Release][badge-release]][latest-release]

This module creates a CloudFront function to perform a simple redirect. By
default it also creates a CloudFront distribution to serve the function. When
redirecting a portion of an existing distribution (e.g. a specific path),
set `create_distribution = false` and attach the function to your distribution
using the `function_arn` output.

> [!NOTE]
> The CloudFront distribution created by this module is not protected by a Web
> Application Firewall (WAF). It's _strongly_ recommended that your destination
> have a WAF in place.

## Usage

Add this module to your `main.tf` (or appropriate) file and configure the inputs
to match your desired configuration. For example:

```hcl
module "redirect" {
  source = "github.com/codeforamerica/tofu-modules-aws-cloudfront-redirect?ref=1.0.0"

  source_domain  = "my-project.org"
  destination    = "https://www.my-project.org"
  logging_bucket = module.logging.bucket
}
```
To attach the redirect function to an existing distribution instead:

```hcl
module "redirect" {
  source = "github.com/codeforamerica/tofu-modules-aws-cloudfront-redirect?ref=1.0.0"

  create_distribution = false
  source_domain       = "my-project.org"
  destination         = "https://www.my-project.org/new-path"
}

resource "aws_cloudfront_distribution" "existing" {
  # ... your existing configuration ...

  ordered_cache_behavior {
    path_pattern = "/old-path/*"
    # ... other required settings ...

    function_association {
      event_type   = "viewer-request"
      function_arn = module.redirect.function_arn
    }
  }
}
```

Make sure you re-run `tofu init` after adding the module to your configuration.

```bash
tofu init
tofu plan
```

## Inputs

| Name             | Description                                                                                                                                     | Type          | Default | Required |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ------- | -------- |
| destination      | Destination for redirects, including scheme (e.g. https://my.domain.com).                                                                       | `string`      | n/a     | yes      |
| logging_bucket   | The S3 bucket used for logging. Required when `create_distribution` is `true`.                                                                  | `string`      | `null`  | no       |
| source_domain    | Domain to redirect from. This should match the hosted zone when creating verification records.                                                  | `string`      | n/a     | yes      |
| create_distribution | Create a new CloudFront distribution. Set to `false` to only create the redirect function and attach it to an existing distribution via the `function_arn` output. | `bool` | `true` | no |
| create_records   | Create DNS records using Route 53. A hosted zone matching the source domain must exist. If `false`, the certificate must be manually validated. Only applies when `create_distribution` is `true`.  | `bool`        | `true`  | no       |
| forward_query    | Forward the incoming request's query string to the destination.                                                                                 | `bool`        | `true`  | no       |
| path             | Optional path to match for the redirect. When set, only requests where the URI starts with this path are redirected. When `null`, all requests are redirected. | `string` | `null` | no |
| source_subdomain | Optional subdomain for the source redirect. Required if the fully qualified domain name (FQDN) is a subdomain of the hosted zone domain.        | `string`      | `null`  | no       |
| static           | Redirect to the destination without passing the path.                                                                                           | `bool`        | `false` | no       |
| status_code      | HTTP status code for the redirect. Must be either 301 (permanent) or 302 (temporary).                                                           | `number`      | `301`   | no       |
| tags             | Tags to apply to all resources.                                                                                                                 | `map(string)` | `{}`    | no       |
| track_referrer   | Capture the incoming `Referer` header and forward it to the destination as a `ref` query parameter.                                             | `bool`        | `false` | no       |

## Outputs

| Name                           | Description                                                                   | Type          |
| ------------------------------ | ----------------------------------------------------------------------------- | ------------- |
| certificate_validation_records | The DNS records required to validate the ACM certificate. Only populated when `create_distribution` is `true`.                      | `map(string)`      |
| cloudfront_dns                 | DNS information for the CloudFront distribution needed to create DNS records. Only populated when `create_distribution` is `true`.  | `map(string)` |
| function_arn                   | The ARN of the CloudFront redirect function.                                                                   | `string`      |
| url                            | The fully qualified URL for the redirect.                                     | `string`      |


## Contributing

Follow the [contributing guidelines][contributing] to contribute to this
repository.

[badge-release]: https://img.shields.io/github/v/release/codeforamerica/tofu-modules-aws-cloudfront-redirect?logo=github&label=Latest%20Release
[contributing]: CONTRIBUTING.md
[latest-release]: https://github.com/codeforamerica/tofu-modules-aws-cloudfront-redirect/releases/latest
