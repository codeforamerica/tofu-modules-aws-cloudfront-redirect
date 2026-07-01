locals {
  fqdn      = join(".", compact([var.source_subdomain, var.source_domain]))
  path_slug = var.path != null ? "-${replace(trim(var.path, "/"), "/", "-")}" : ""
  name      = "redirect-${replace(local.fqdn, ".", "-")}${local.path_slug}"
  tags      = merge(var.tags, { use : "redirect" })
}
