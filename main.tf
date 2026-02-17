
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

module "network_151" {
  source                = "./modules/network"
  ocp_namespace         = "default"
  ocp_ovs_localnet_name = "br1-localnet"
  tenant_name           = "OXXO"
  vrf_name              = "OX_Prd_VRF"
  application_profile   = "OX_Prd_AP"
  network_name          = "Net_151"
  vlan_id               = 151
  physical_domain_name  = "OXXO_PhysDom"
  network_subnet        = "10.184.151.0/24"

}

module "vm_test_1" {
  source               = "./modules/virtual_machine"
  ocp_namespace        = "default"
  vm_name              = "vm-1"
  memory               = 2
  network_name         = "Net_151"
  network_subnet       =  module.network_151.network_range
  network_gateway      =  module.network_151.network_gateway
  container_disk_image = "quay.io/containerdisks/fedora:latest"
}

module "vm_test_2" {
  source               = "./modules/virtual_machine"
  ocp_namespace        = "default"
  vm_name              = "vm-2"
  memory               = 2
  network_name         = "Net_151"
  network_subnet       =  module.network_151.network_range
  network_gateway      =  module.network_151.network_gateway
  container_disk_image = "quay.io/containerdisks/fedora:latest"
}