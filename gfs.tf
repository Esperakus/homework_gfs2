resource "yandex_compute_instance" "ansible" {

  name     = "ansible"
  hostname = "ansible"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    #    ssh-keys = "cloud-user:${file("~/.ssh/id_rsa.pub")}"
    ssh-keys = "cloud-user:${tls_private_key.ssh.public_key_openssh}"
  }

  connection {
    type        = "ssh"
    user        = "cloud-user"
    private_key = tls_private_key.ssh.private_key_pem
    host        = self.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'host is up'",
      "sudo dnf install -y epel-release",
      "sudo dnf install -y ansible"
    ]
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/home/cloud-user"

  }

  provisioner "file" {
    source      = "id_rsa"
    destination = "/home/cloud-user/.ssh/id_rsa"

  }

  provisioner "file" {
    source      = "id_rsa.pub"
    destination = "/home/cloud-user/.ssh/id_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/cloud-user/.ssh/id_rsa"
    ]

  }

  provisioner "file" {
    source      = "./ansible/ansible.cfg"
    destination = "/home/cloud-user/ansible.cfg"

  }

  provisioner "remote-exec" {
    # command = "ansible-playbook -u cloud-user -i '${self.network_interface.0.nat_ip_address},' --private-key id_rsa nginx.yml"
    inline = [
      "ansible-playbook -u cloud-user -i /home/cloud-user/ansible/hosts /home/cloud-user/ansible/playbooks/main.yml"
    ]
  }

  depends_on = [
    yandex_compute_instance.gfs,
    yandex_compute_instance.iscsi,
  ]
}

resource "yandex_compute_instance" "gfs" {

  count    = 3
  name     = "gfs${count.index}"
  hostname = "gfs${count.index}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    # nat       = true
  }

  metadata = {
    ssh-keys = "cloud-user:${tls_private_key.ssh.public_key_openssh}"
  }

}

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
    disk_id = yandex_compute_disk.iscsi.id
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