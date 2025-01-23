resource "yandex_mdb_redis_cluster" "sentry" {
  name        = "sentry"
  folder_id   = local.folder_id
  network_id  = yandex_vpc_network.sentry.id
  environment = "PRODUCTION"

  config {
    password         = "secretpassword"
    maxmemory_policy = "ALLKEYS_LRU"
    version     = "7.2"
  }

  resources {
    resource_preset_id = "hm1.nano"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.sentry-a.id
  }
}
