# Set environment variables in shell or pipeline before running
#
# export TF_VAR_username="admin"
# export TF_VAR_password="automation"
#

terraform {
    required_version = "= 1.13.3"
    required_providers {
        iosxe = {
            source = "CiscoDevNet/iosxe"
            version = "0.18.0"
        }
    }
}

provider "iosxe" {
    host = var.host
    username = var.username
    password = var.password
    protocol = "netconf"
}


data "iosxe_vlan" "default_vlan" {
  vlan_id = 1
}

resource "iosxe_vlan" vlans {
    for_each = var.vlans
    vlan_id = each.value.id
    name = each.value.name
    shutdown = try(each.value.shutdown, false)
}