# Note to developers: This file shows some examples that you may
# want to use in order to configure this template. It is your
# responsibility to choose the values that make sense for your application.
#
# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name collision, consider using different values for
# the `name` variable or increasing the value for `randomization_level`.

resource_group_location             = "eastus"
name                                = "az-vm-web-server"
randomization_level                 = 8
os_profile_computer_name            = "webservervm"
os_profile_admin_username           = "webservervm"
storage_os_disk_name                = "dskmain"
azurerm_network_security_group_name = "nsgmain"
azurerm_network_interface_name      = "nicmain"
azurerm_virtual_network_name        = "vnetmain"
