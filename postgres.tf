module "postgresql_cluster" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-mdb-postgresql.git?ref=v1.0.0"

  name        = "sentry"
  network_id  = yandex_vpc_network.sentry.id
  description = "My PostgreSQL cluster description"
  folder_id   = local.folder_id

  postgresql_version = "15"

  resource_preset_id = "s2.micro"
  disk_type_id       = "network-ssd"
  disk_size          = 34

  hosts = [
    {
      zone             = "ru-central1-a"
      subnet_id        = yandex_vpc_subnet.sentry-a.id
      assign_public_ip = true
      name             = "host-a"
      priority         = 1
    },
    {
      zone             = "ru-central1-b"
      subnet_id        = yandex_vpc_subnet.sentry-b.id
      assign_public_ip = true
      name             = "host-b"
      priority         = 2
    },
    {
      zone             = "ru-central1-d"
      subnet_id        = yandex_vpc_subnet.sentry-d.id
      assign_public_ip = true
      name             = "host-d"
      priority         = 2
    },
  ]

  database_name  = "sentry"
  database_owner = "sentry"
  lc_collate     = "en_US.UTF-8"
  lc_type        = "en_US.UTF-8"

  extensions = [
    {
      name = "citext"
    }
  ]

  user_name       = "sentry"
  user_password   = "my_password"
  user_conn_limit = 50

}
