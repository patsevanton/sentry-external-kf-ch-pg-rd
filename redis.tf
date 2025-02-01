resource "yandex_mdb_redis_cluster" "sentry" {
  name        = "sentry"
  folder_id   = local.folder_id
  network_id  = yandex_vpc_network.sentry.id
  environment = "PRODUCTION"

  config {
    password         = local.redis_password
    maxmemory_policy = "ALLKEYS_LRU"
    version     = "7.2"
  }

  resources {
    resource_preset_id = "hm3-c2-m8"
    disk_type_id       = "network-ssd"
    disk_size          = 65
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.sentry-a.id
  }
}

output "externalRedis" {
  value = {
    host     = yandex_mdb_redis_cluster.sentry.host[0].fqdn
    port     = 6379
    password = local.redis_password
  }
}
