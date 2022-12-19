output "external_ip_address_ansible" {
  value = yandex_compute_instance.ansible.*.network_interface.0.nat_ip_address
}

output "internal_ip_address_gfs" {
  value = yandex_compute_instance.gfs.*.network_interface.0.ip_address
}

output "internal_ip_address_iscsi" {
  value = yandex_compute_instance.iscsi.*.network_interface.0.ip_address
}
