locals {
  dns_records = [
    "@",
    "abyss",
    "cdn",
    "gpt",
    "hello-world-direct",
    "send",
    "ts",
    "youtubedl"
  ]
  proxied_records = {
    "cdn" = true,
    "@"   = true,
  }
}

data "cloudflare_dns_record" "home" {
  zone_id = var.cloudflare_zone_id
  filter = {
    name = {
      exact = "home.${data.cloudflare_zone.main.name}"
    }
    type  = "A"
    match = "all"
  }
}

resource "cloudflare_dns_record" "dns" {
  for_each = toset(local.dns_records)

  zone_id = var.cloudflare_zone_id
  name    = each.key
  type    = "CNAME"
  content = data.cloudflare_dns_record.home.name
  ttl     = 1
  proxied = lookup(local.proxied_records, each.key, false)
}

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}
