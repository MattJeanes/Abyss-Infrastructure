resource "azurerm_managed_disk" "teamspeak" {
  name                 = "teamspeak"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

output "teamspeak_disk_id" {
  value = azurerm_managed_disk.teamspeak.id
  sensitive = true
}