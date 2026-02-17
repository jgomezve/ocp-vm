output "network_gateway" {
  value = menandmice_ipam_record.gateway.address
}

output "network_range" {
  value = var.network_subnet
}