data "azurerm_resource_group" "apimgmt" {
  name      = "${var.service_plan_resource_group_name}"
}

resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name}"
  location            = "${data.azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"
  tags                = "${var.resource_tags}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}

# resource "azurerm_api_management_api" "apimgmt" {
#   name                = "${var.api_name}"
#   resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
#   api_management_name = "${azurerm_api_management.apimgmt.name}"
#   revision            = "${var.revision}"
#   display_name        = "${var.display_name}"
#   path                = "${var.path}"
#   protocols           = "${var.protocols}"
#   service_url         = "${var.service_url}"
# }
