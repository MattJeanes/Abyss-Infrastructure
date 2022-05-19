resource "azurerm_role_definition" "diskaccess" {
  name        = "Disk Access"
  scope       = data.azurerm_subscription.current.id
  description = "Allows access to disks"

  permissions {
    actions     = ["Microsoft.Compute/disks/read"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}
