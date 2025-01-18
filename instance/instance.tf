data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "default" {
  name        = "sentry-instance"
  platform_id = "standard-v3"
  zone        = yandex_vpc_subnet.sentry-b.zone

  resources {
    cores  = 2
    memory = 8
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sentry-b.id
    nat       = true
  }
}
