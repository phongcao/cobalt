resource "azurerm_resource_group" "main" {
  name     = local.app_rg_name
  location = local.region
}
