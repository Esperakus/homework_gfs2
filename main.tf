terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=3.0.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.yc_token
}
provider "tls" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_ssh" {
  filename        = "id_rsa"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_ssh" {
  filename        = "id_rsa.pub"
  content         = tls_private_key.ssh.public_key_openssh
  file_permission = "0600"
}

resource "local_file" "hosts" {
  filename = "ansible/hosts"
  content = templatefile("hosts.tpl",
    {
      gfs_workers   = yandex_compute_instance.gfs.*.network_interface.0.ip_address
      iscsi_workers = yandex_compute_instance.iscsi.*.network_interface.0.ip_address
    }
  )
  depends_on = [
    yandex_compute_instance.gfs,
    yandex_compute_instance.iscsi,
    # yandex_compute_instance.db,
  ]
}