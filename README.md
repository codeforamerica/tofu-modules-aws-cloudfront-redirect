# AWS CloudFront Redirect Module

[![GitHub Release][badge-release]][latest-release]

This module creates a CloudFront distrubution and function to create a simple
redirect.

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

Make sure you re-run `tofu init` after adding the module to your configuration.

```bash
tofu init
tofu plan
```

## Inputs

| Name             | Description                                                                                                                                     | Type          | Default | Required |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ------- | -------- |
| destination      | Destination for redirects, including scheme (e.g. https://my.domain.com).                                                                       | `string`      | n/a     | yes      |
| logging_bucket   | The S3 bucket used for logging.                                                                                                                 | `string`      | n/a     | yes      |
| source_domain    | Domain to redirect from. This should match the hosted zone when creating verification records.                                                  | `string`      | n/a     | yes      |
| create_records   | Create DNS records using Route 53. A hosted zone matching the source domain must exist. If `false`, the certificate must be manually validated. | `bool`        | `true`  | no       |
| source_subdomain | Optional subdomain for the source redirect. Required if the fully qualified domain name (FQDN) is a subdomain of the hosted zone domain.        | `string`      | `null`  | no       |
| static           | Redirect to the destination without passing the path.                                                                                           | `bool`        | `false` | no       |
| status_code      | HTTP status code for the redirect. Must be either 301 (permanent) or 302 (temporary).                                                           | `number`      | `301`   | no       |
| tags             | Tags to apply to all resources.                                                                                                                 | `map(string)` | `{}`    | no       |

## Outputs

| Name                           | Description                                                                   | Type          |
| ------------------------------ | ----------------------------------------------------------------------------- | ------------- |
| certificate_validation_records | The DNS records required to validate the ACM certificate.                     | `string`      |
| cloudfront_dns                 | DNS information for the CloudFront distribution needed to create DNS records. | `map(string)` |
| url                            | The fully qualified URL for the redirect.                                     | `string`      |


## Contributing

Follow the [contributing guidelines][contributing] to contribute to this
repository.

[badge-release]: https://img.shields.io/github/v/release/codeforamerica/tofu-modules-aws-cloudfront-redirect?logo=github&label=Latest%20Release
[contributing]: CONTRIBUTING.md
[latest-release]: https://github.com/codeforamerica/tofu-modules-aws-cloudfront-redirect/releases/latest
