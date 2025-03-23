resource "cloudflare_zero_trust_access_policy" "access_tokens" {
  account_id = var.cloudflare_account_id
  name       = "Access tokens"
  decision   = "non_identity"
  include = [{
    any_valid_service_token = {}
  }]
}

resource "cloudflare_zero_trust_access_policy" "allowed_users" {
  account_id = var.cloudflare_account_id
  name       = "Allowed users"
  decision   = "allow"
  include = [{
    email = {
      email = var.email
    }
  }]
}


resource "cloudflare_zero_trust_access_application" "kubernetes_api" {
  account_id = var.cloudflare_account_id
  name       = "Kubernetes API"
  type       = "self_hosted"
  destinations = [{
    type = "public"
    uri  = "kubernetes-api.${data.cloudflare_zone.main.name}"
  }]

  # Seems to be broken in the current Cloudflare provider, added manually for now
  #   policies = [
  #     {
  #       id         = cloudflare_zero_trust_access_policy.allowed_users.id
  #       precedence = 0
  #     },
  #     {
  #       id         = cloudflare_zero_trust_access_policy.access_tokens.id
  #       precedence = 1
  #     }
  #   ]

  # This doesn't exist in the current Cloudflare provider, added manually for now
  # instant_auth = true

}

resource "cloudflare_zero_trust_tunnel_cloudflared" "ryzen7_5800u_01" {
  account_id = var.cloudflare_account_id
  name       = "ryzen7-5800u-01"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "ryzen7_5800u_01" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01]
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01.id
  config = {
    ingress = [
      {
        hostname = "kubernetes-api.${data.cloudflare_zone.main.name}"
        service  = "tcp://kubernetes:443"
        origin_request = {
          access = {
            required  = true
            aud_tag   = [cloudflare_zero_trust_access_application.kubernetes_api.aud]
            team_name = "abyss23"
          }
        }
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "kubernetes_api" {
  depends_on = [cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01]
  zone_id    = var.cloudflare_zone_id
  name       = "kubernetes-api"
  type       = "CNAME"
  content    = "${cloudflare_zero_trust_tunnel_cloudflared.ryzen7_5800u_01.id}.cfargotunnel.com"
  ttl        = 1
  proxied    = true
}
