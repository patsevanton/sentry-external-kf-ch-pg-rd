data "yandex_client_config" "client" {}

resource "random_password" "kafka" {
  length      = 20
  special     = false
  min_numeric = 4  # Минимум 4 цифры
  min_upper   = 4  # Минимум 4 заглавные буквы
}

resource "random_password" "clickhouse" {
  length      = 20
  special     = false
  min_numeric = 4
  min_upper   = 4
}

resource "random_password" "redis" {
  length      = 20
  special     = false
  min_numeric = 4
  min_upper   = 4
}

resource "random_password" "postgres" {
  length      = 20
  special     = false
  min_numeric = 4
  min_upper   = 4
}

resource "random_password" "sentry_admin_password" {
  length      = 20
  special     = false
  min_numeric = 4
  min_upper   = 4
}

locals {
  folder_id           = data.yandex_client_config.client.folder_id
  k8s_version         = "1.30"
  number_of_k8s_hosts = 3
  boot_disk           = 128 # GB
  memory_of_k8s_hosts = 20
  cores_of_k8s_hosts  = 4
  sentry_admin_password = random_password.sentry_admin_password.result
  kafka_user          = "sentry"
  kafka_password      = random_password.kafka.result
  clickhouse_user     = "sentry"
  clickhouse_password = random_password.clickhouse.result
  redis_password      = random_password.redis.result
  postgres_password   = random_password.postgres.result
  filestore_bucket    = "sentry-bucket-apatsev-filestore-test"
  nodestore_bucket    = "sentry-bucket-apatsev-nodestore-test"
}

output "generated_passwords" {
  description = "Map of generated passwords for services"
  value = {
    kafka_password      = random_password.kafka.result
    clickhouse_password = random_password.clickhouse.result
    redis_password      = random_password.redis.result
    postgres_password   = random_password.postgres.result
  }
  sensitive = true  # Скрывает пароли в логах, но доступны через `terraform output`
}
