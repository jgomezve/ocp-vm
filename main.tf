
terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "2.18.0"
    }
    menandmice = {
      source  = "menandmice/menandmice"
      version = "0.4.1"
    }
  }
}

provider "aci" {
  username = "admin"
  password = "Cisco12345."
  url      = "https://198.18.167.1"
  insecure = true
}

provider "menandmice" {
  endpoint   = "http://198.18.157.157"
  username   = "administrator"
  password   = "administrator"
  tls_verify = false
}

provider "kubernetes" {
  # config_path = "~/.kube/config"
}


module "network" {
  for_each              = { for net in var.networks : net.name => net }
  source                = "./modules/network"
  ocp_namespace         = var.ocp_namespace
  ocp_ovs_localnet_name = var.ocp_ovs_localnet_name
  tenant_name           = each.value.tenant_name
  vrf_name              = each.value.vrf_name
  application_profile   = each.value.application_profile
  network_name          = each.value.name
  vlan_id               = each.value.vlan_id
  physical_domain_name  = "OXXO_PhysDom"
  network_subnet        = each.value.network_subnet

}

module "vm_test_1" {
  for_each             = { for vm in var.vms : vm.name => vm }
  source               = "./modules/virtual_machine"
  ocp_namespace        = var.ocp_namespace
  vm_name              = each.value.name
  memory               = each.value.memory
  network_name         = each.value.network_name
  network_subnet       = module.network[each.value.network_name].network_range
  network_gateway      = module.network[each.value.network_name].network_gateway
  container_disk_image = each.value.container_disk_image
}
