data "aci_tenant" "tenant" {
  name = var.tenant_name
}

data "aci_vrf" "vrf" {
  parent_dn = data.aci_tenant.tenant.id
  name  = var.vrf_name
}

data "aci_application_profile" "app_profile" {
  parent_dn = data.aci_tenant.tenant.id
  name  = var.application_profile
}

resource "aci_bridge_domain" "bd" {
  parent_dn = data.aci_tenant.tenant.id
  name  = "Vl${var.vlan_id}_BD"
  relation_to_vrf = {
    vrf_name   = data.aci_vrf.vrf.name
  }
}

resource "aci_application_epg" "epg" {
  parent_dn = data.aci_application_profile.app_profile.id
  name      = "OpsVl${var.vlan_id}_EPG"
  preferred_group_member = "include"
  relation_to_bridge_domain = {
    bridge_domain_name = aci_bridge_domain.bd.name
  }
}

resource "aci_relation_to_domain" "phy_dom" {
  parent_dn = aci_application_epg.epg.id
  target_dn = "uni/phys-${var.physical_domain_name}"
}

resource "aci_epg_to_static_path" "example" {
  application_epg_dn  = aci_application_epg.epg.id
  tdn  = "topology/pod-${var.pod_id}/paths-${var.node_id}/pathep-[eth1/${var.interface_id}]"
  encap  = "vlan-${var.vlan_id}"
  mode  = "regular"
}

resource "menandmice_range" "ipam_range" {
  cidr   =  var.network_subnet
  title  = "Network ${var.network_name}"
  subnet = true
}

resource "menandmice_ipam_record" "gateway" {
  free_ip {
    range = menandmice_range.ipam_range.name
  }
}

resource "aci_subnet" "gateway" {
  parent_dn   = aci_bridge_domain.bd.id
  ip          = "${menandmice_ipam_record.gateway.address}/${split("/", var.network_subnet)[1]}"
}


resource "kubernetes_manifest" "nad" {
  manifest = {
    apiVersion = "k8s.cni.cncf.io/v1"
    kind       = "NetworkAttachmentDefinition"

    metadata = {
      name      = var.network_name
      namespace = var.ocp_namespace
    }

    spec = {
      config = jsonencode({
        cniVersion          = "0.3.1"
        name                = var.network_name
        type                = "ovn-k8s-cni-overlay"
        topology            = "localnet"
        physicalNetworkName = var.ocp_ovs_localnet_name
        # mtu                 = each.value.mtu
        vlanID              = var.vlan_id
        netAttachDefName    = "${var.ocp_namespace}/${var.network_name}"
      })
    }
  }
}