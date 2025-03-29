resource "yandex_mdb_clickhouse_cluster" "sentry" {
  folder_id   = local.folder_id
  name        = "sentry"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.sentry.id
  version     = 24.8

  clickhouse {
    resources {
      resource_preset_id = "s3-c2-m8"
      disk_type_id       = "network-ssd"
      disk_size          = 70
    }
  }

  zookeeper {
    resources {
      resource_preset_id = "s3-c2-m8"
      disk_type_id       = "network-ssd"
      disk_size          = 34
    }
  }

  database {
    name = "sentry"
  }

  user {
    name     = local.clickhouse_user
    password = local.clickhouse_password
    permission {
      database_name = "sentry"
    }
  }

  host {
    type      = "CLICKHOUSE"
    zone      = yandex_vpc_subnet.sentry-a.zone
    subnet_id = yandex_vpc_subnet.sentry-a.id
  }

  host {
    type      = "ZOOKEEPER"
    zone      = yandex_vpc_subnet.sentry-a.zone
    subnet_id = yandex_vpc_subnet.sentry-a.id
  }

  host {
    type      = "ZOOKEEPER"
    zone      = yandex_vpc_subnet.sentry-b.zone
    subnet_id = yandex_vpc_subnet.sentry-b.id
  }

  host {
    type      = "ZOOKEEPER"
    zone      = yandex_vpc_subnet.sentry-d.zone
    subnet_id = yandex_vpc_subnet.sentry-d.id
  }

}

output "externalClickhouse" {
  value = {
    host     = yandex_mdb_clickhouse_cluster.sentry.host[0].fqdn
    database = one(yandex_mdb_clickhouse_cluster.sentry.database[*].name)
    httpPort = 8123
    tcpPort  = 9000
    username = local.clickhouse_user
    password = local.clickhouse_password
  }
  sensitive = true
}