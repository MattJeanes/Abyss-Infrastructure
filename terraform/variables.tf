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

variable "windows_server_password" {
  sensitive = true
}
