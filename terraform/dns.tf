locals {
  dns_records = [
    "@",
    "abyss",
    "auth",
    "cdn",
    "gpt",
    "influxdb",
    "musicbot",
    "send",
    "teslamate",
    "torrent",
    "ts",
    "youtubedl"
  ]
  proxied_records = {
    "musicbot"    = true,
    "cdn"         = true,
    "@"           = true,
  }
}

resource "cloudflare_dns_record" "dns" {
  for_each = toset(local.dns_records)

  zone_id = var.cloudflare_zone_id
  name    = each.key
  type    = "CNAME"
  content = azurerm_public_ip.abyss_public.fqdn
  ttl     = 1
  proxied = lookup(local.proxied_records, each.key, false)
}

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}
