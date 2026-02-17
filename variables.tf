variable "ocp_namespace" {
  type = string
}

variable "ocp_ovs_localnet_name" {
  type = string
}


variable "networks" {

  type = list(object({
    tenant_name         = string
    vrf_name            = string
    application_profile = string
    name                = string
    vlan_id             = number
    network_subnet      = string
  }))

  default = []

}

variable "vms" {
  type = list(object({
    name                 = string
    memory               = number
    network_name         = string
    container_disk_image = string
    dns                  = optional(string)
    username             = optional(string)
    password             = optional(string)
  }))

  default = []
}