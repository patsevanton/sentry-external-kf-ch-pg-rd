data "yandex_client_config" "client" {}

locals {
  folder_id           = ""
  k8s_version         = "1.30"
  number_of_k8s_hosts = 3
  boot_disk           = 128 # GB
  memory_of_k8s_hosts = 20
  cores_of_k8s_hosts  = 4
  kafka_user          = "sentry"
  kafka_password      = "your_password_here"
  clickhouse_user     = "sentry"
  clickhouse_password = "your_password_here"
  redis_password      = "secretpassword"
}
