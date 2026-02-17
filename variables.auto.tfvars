ocp_namespace         = "default"
ocp_ovs_localnet_name = "br1-localnet"

networks = [
  {
    name                = "nad-aci-vlan-151"
    vlan_id             = 151
    tenant_name         = "OXXO"
    vrf_name            = "OX_Prd_VRF"
    application_profile = "OX_Prd_AP"
    network_subnet      = "10.184.151.0/24"
  },
  {
    name                = "nad-aci-vlan-152"
    vlan_id             = 152
    tenant_name         = "OXXO"
    vrf_name            = "OX_Prd_VRF"
    application_profile = "OX_Prd_AP"
    network_subnet      = "10.184.152.0/24"
  }
]

vms = [
  {
    name                 = "vm-1"
    memory               = 2
    network_name         = "nad-aci-vlan-151"
    container_disk_image = "quay.io/containerdisks/fedora:latest"
  },
  {
    name                 = "vm-2"
    memory               = 2
    network_name         = "nad-aci-vlan-152"
    container_disk_image = "quay.io/containerdisks/fedora:latest"
  }
]