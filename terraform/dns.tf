locals {
  dns_records = {
    "hello-world" = "hello-world",
  }
  proxied_records = {
    "hello-world" = true,
  }
}

resource "cloudflare_record" "dns" {
  for_each = local.dns_records
  zone_id  = var.cloudflare_zone_id
  name     = each.value
  type     = "CNAME"
  value    = azurerm_public_ip.abyss_public.fqdn
  ttl      = 1
  proxied  = lookup(local.proxied_records, each.key, false)
}
