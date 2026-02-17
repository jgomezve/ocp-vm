
resource "menandmice_ipam_record" "ip" {
  free_ip {
    range = var.network_subnet
  }
}

resource "kubernetes_manifest" "vm" {
  manifest = {
    apiVersion = "kubevirt.io/v1"
    kind       = "VirtualMachine"

    metadata = {
      name      = var.vm_name
      namespace = var.ocp_namespace
    }

    spec = {
      running = true
      template = {
        spec = {
          domain = {
            devices = {
              disks = [
                {
                  name = "containerdisk"
                  disk = {
                    bus = "virtio"
                  }
                },
                {
                  name = "cloudinitdisk"
                  disk = {
                    bus = "virtio"
                  }
                }
              ]

              interfaces = [
                {
                  name       = "default-nic"
                  masquerade = {}
                },
                {
                  name   = "vm-net"
                  model  = "virtio"
                  bridge = {}
                  state  = "up"
                }
              ]
            }

            resources = {
              requests = {
                memory = "${var.memory}Gi"
              }
            }
          }

          networks = [
            {
              name = "default-nic"
              pod  = {}
            },
            {
              name = "vm-net"
              multus = {
                networkName = var.network_name
              }
            }
          ]

          volumes = [
            {
              name = "containerdisk"
              containerDisk = {
                image = var.container_disk_image
              }
            },
            {
              name = "cloudinitdisk"
              cloudInitNoCloud = {
                networkData = templatefile(
                  "${path.module}/templates/cloudinit-network.yaml.tmpl",
                  {
                    ip_address = menandmice_ipam_record.ip.address
                    gateway    = var.network_gateway
                    dns        = var.dns_ip
                  }
                )
                userData = templatefile(
                  "${path.module}/templates/cloudinit-user.yaml.tmpl",
                  {
                    username = var.username
                    password = var.password
                  }
                )
              }
            }
          ]
        }
      }
    }
  }
}