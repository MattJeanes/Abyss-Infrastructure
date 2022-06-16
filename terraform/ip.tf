resource "azurerm_public_ip" "abyss_public" {
  name                = "abyss-public-ip"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  allocation_method   = "Static"
  domain_name_label   = "abyss-public"
  sku                 = "Basic"
}

output "public_ip_address" {
  value = azurerm_public_ip.abyss_public.ip_address
  sensitive = true
}
