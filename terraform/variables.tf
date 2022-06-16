variable "kubernetes_version" {
  sensitive = false
}

variable "ssh_public_key" {
  sensitive = true
}

variable "cloudflare_api_token" {
  sensitive = true
}

variable "cloudflare_zone_id" {
  sensitive = true
}

variable "home_ip" {
  sensitive = true
}

variable "mariadb_root_password" {
  sensitive = true
}

variable "grafana_admin_password" {
  sensitive = true
}

variable "pagerduty_url" {
  sensitive = true
}

variable "pagerduty_integration_key" {
  sensitive = true
}

variable "dead_mans_snitch_webhook_url" {
  sensitive = true
}

variable "teamspeak_serveradmin_password" {
  sensitive = true
}

variable "teamspeak_database_password" {
  sensitive = true
}
