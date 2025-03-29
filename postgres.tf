resource "yandex_mdb_postgresql_cluster" "postgresql_cluster" {
  name                = "sentry"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.sentry.id

  config {
    version = "15"
    autofailover = true
    backup_retain_period_days = 7

    resources {
      disk_size          = 129
      disk_type_id       = "network-ssd"
      resource_preset_id = "s3-c2-m8"
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.sentry-a.id
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.sentry-b.id
  }

  host {
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.sentry-d.id
  }

}

resource "yandex_mdb_postgresql_database" "postgresql_database" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql_cluster.id
  name       = "sentry"
  owner      = yandex_mdb_postgresql_user.postgresql_user.name

  extension {
    name = "citext"
  }

  depends_on = [yandex_mdb_postgresql_user.postgresql_user]
}

resource "yandex_mdb_postgresql_user" "postgresql_user" {
  cluster_id = yandex_mdb_postgresql_cluster.postgresql_cluster.id
  name       = "sentry"
  password   = local.postgres_password
  conn_limit = 50
  grants     = []
}

output "externalPostgresql" {
  value = {
    password = local.postgres_password
    host     = "c-${yandex_mdb_postgresql_cluster.postgresql_cluster.id}.rw.mdb.yandexcloud.net"
    port     = 6432
    username = yandex_mdb_postgresql_user.postgresql_user.name
    database = yandex_mdb_postgresql_database.postgresql_database.name
  }
  sensitive = true
}
