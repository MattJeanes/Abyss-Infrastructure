locals {
  dns_records = [
    "@",
    "abyss",
    "alertmanager",
    "api.kubernetes",
    "auth",
    "cdn",
    "gpt",
    "grafana",
    "hello-world",
    "influxdb",
    "musicbot",
    "prometheus",
    "send",
    "teslamate",
    "torrent",
    "ts",
    "youtubedl"
  ]
  proxied_records = {
    "hello-world" = true,
    "musicbot"    = true,
    "cdn"         = true,
    "@"           = true
  }
  migrated_records = {
    "hello-world" = true
    "api.kubernetes" = true,
    "alertmanager" = true,
    "grafana" = true,
    "prometheus" = true,
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
  content = lookup(local.migrated_records, each.key, false) ? data.cloudflare_dns_record.home.name : azurerm_public_ip.abyss_public.fqdn
  ttl     = 1
  proxied = lookup(local.proxied_records, each.key, false)
}

data "cloudflare_zone" "main" {
  zone_id = var.cloudflare_zone_id
}
