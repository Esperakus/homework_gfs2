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
      "sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm",
      "sudo dnf update -y",
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

  # provisioner "remote-exec" {
  #   inline = [
  # "ansible-playbook -u cloud-user -i /home/cloud-user/ansible/hosts /home/cloud-user/ansible/playbooks/main.yml",
  # "ssh gfs-server0 'sudo pcs property set no-quorum-policy=freeze'",
  # "ssh gfs-server0 'sudo pcs resource create dlm ocf:pacemaker:controld op monitor interval=30s on-fail=ignore --group locking'",
  # "ssh gfs-server0 'sudo pcs resource clone locking interleave=true'",
  # "ssh gfs-server0 'sudo pcs resource create lvmlockdd ocf:heartbeat:lvmlockd op monitor interval=30s on-fail=ignore --group locking'",
  # "ssh gfs-server0 'sudo pvcreate /dev/sda'",
  # "ssh gfs-server0 'sudo vgcreate --shared vg_gfs2 /dev/sda'",
  # "ssh gfs-server1 'sudo vgchange --lock-start vg_gfs2'",
  # "ssh gfs-server2 'sudo vgchange --lock-start vg_gfs2'",
  # "ssh gfs-server0 'sudo lvcreate -l 100%FREE -n lv_gfs2 vg_gfs2; mkfs.gfs2 -j2 -p lock_dlm -t ha_cluster:gfs2-01 /dev/vg_gfs2/lv_gfs2'",
  # "ssh gfs-server0 'sudo pcs resource create shared_lv ocf:heartbeat:LVM-activate lvname=lv_gfs2 vgname=vg_gfs2 activation_mode=shared vg_access_mode=lvmlockd --group shared_vg'",
  # "ssh gfs-server0 'sudo pcs resource clone shared_vg interleave=true'",
  # "ssh gfs-server0 'sudo pcs constraint order start locking-clone then shared_vg-clone'",
  # "ssh gfs-server0 'sudo pcs constraint colocation add shared_vg-clone with locking-clone'",
  # "ssh gfs-server0 'sudo pcs resource create shared_fs ocf:heartbeat:Filesystem device=/dev/vg_gfs2/lv_gfs2 directory=/home/gfs2-share fstype=gfs2 options=noatime op monitor interval=10s on-fail=fence --group shared_vg'",
  # "ssh gfs-server0 'pcs cluster start --all'",
  #   ]
  # }

  depends_on = [
    yandex_compute_instance.gfs,
    yandex_compute_instance.iscsi,
  ]
}