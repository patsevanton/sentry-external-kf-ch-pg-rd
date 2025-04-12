# Ресурс для создания сети VPC в Yandex Cloud
resource "yandex_vpc_network" "sentry" {
  name      = "vpc"  # Имя сети VPC
  folder_id = coalesce(local.folder_id, data.yandex_client_config.client.folder_id)  # ID папки, либо из локальной переменной, либо из конфигурации клиента Yandex Cloud
}

# Ресурс для создания подсети в зоне "ru-central1-a"
resource "yandex_vpc_subnet" "sentry-a" {
  folder_id      = coalesce(local.folder_id, data.yandex_client_config.client.folder_id)  # ID папки, либо из локальной переменной, либо из конфигурации клиента Yandex Cloud
  v4_cidr_blocks = ["10.0.1.0/24"]  # CIDR блок для подсети (IP-диапазон)
  zone           = "ru-central1-a"  # Зона, где будет размещена подсеть
  network_id     = yandex_vpc_network.sentry.id  # ID сети, к которой будет привязана подсеть
}

# Ресурс для создания подсети в зоне "ru-central1-b"
resource "yandex_vpc_subnet" "sentry-b" {
  folder_id      = coalesce(local.folder_id, data.yandex_client_config.client.folder_id)  # ID папки, либо из локальной переменной, либо из конфигурации клиента Yandex Cloud
  v4_cidr_blocks = ["10.0.2.0/24"]  # CIDR блок для подсети (IP-диапазон)
  zone           = "ru-central1-b"  # Зона, где будет размещена подсеть
  network_id     = yandex_vpc_network.sentry.id  # ID сети, к которой будет привязана подсеть
}

# Ресурс для создания подсети в зоне "ru-central1-d"
resource "yandex_vpc_subnet" "sentry-d" {
  folder_id      = coalesce(local.folder_id, data.yandex_client_config.client.folder_id)  # ID папки, либо из локальной переменной, либо из конфигурации клиента Yandex Cloud
  v4_cidr_blocks = ["10.0.3.0/24"]  # CIDR блок для подсети (IP-диапазон)
  zone           = "ru-central1-d"  # Зона, где будет размещена подсеть
  network_id     = yandex_vpc_network.sentry.id  # ID сети, к которой будет привязана подсеть
}
