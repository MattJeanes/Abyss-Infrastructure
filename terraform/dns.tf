locals {
  dns_records = [
    "hello-world",
    "abyss",
    "gpt",
    "alertmanager",
    "grafana",
    "prometheus",
    "auth",
    "ts",
    "musicbot",
    "torrent",
    "teslamate",
    "influxdb",
    "youtubedl",
    "send",
    "cdn",
    "@"
  ]
  proxied_records = {
    "hello-world" = true,
    "musicbot"    = true,
    "cdn"         = true,
    "@"           = true
  }
}

resource "cloudflare_record" "dns" {
  for_each = toset(local.dns_records)

  zone_id = var.cloudflare_zone_id
  name    = each.key
  type    = "CNAME"
  value   = azurerm_public_ip.abyss_public.fqdn
  ttl     = 1
  proxied = lookup(local.proxied_records, each.key, false)
}
