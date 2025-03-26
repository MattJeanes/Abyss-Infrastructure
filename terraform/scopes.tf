resource "azurerm_role_definition" "diskaccess" {
  name        = "Disk Access"
  scope       = data.azurerm_subscription.current.id
  description = "Allows access to disks"

  permissions {
    actions     = ["Microsoft.Compute/disks/read", "Microsoft.Compute/disks/write"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_definition" "diskaccess_old" {
  name        = "Disk Access Old"
  scope       = data.azurerm_subscription.old.id
  description = "Allows access to disks"

  permissions {
    actions     = ["Microsoft.Compute/disks/read", "Microsoft.Compute/disks/write"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.old.id,
  ]
}
