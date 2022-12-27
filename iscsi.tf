resource "yandex_compute_instance" "iscsi" {

  name     = "iscsi"
  hostname = "iscsi"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.iscsi.id
    device_name = "iscsi_disk"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    # nat       = true
  }

  metadata = {
    ssh-keys = "cloud-user:${tls_private_key.ssh.public_key_openssh}"
  }

}

resource "yandex_compute_disk" "iscsi" {
  name = "iscsi-target"
  size = 2
}