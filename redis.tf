# Создание кластера Redis в Yandex Managed Service for Redis
resource "yandex_mdb_redis_cluster" "sentry" {
  name        = "sentry"  # Название кластера
  folder_id   = local.folder_id  # Идентификатор папки в Yandex Cloud
  network_id  = yandex_vpc_network.sentry.id  # ID сети VPC
  environment = "PRODUCTION"  # Среда (может быть PRODUCTION или PRESTABLE)
  tls_enabled = true  # Включение TLS для защищённого подключения

  config {
    password         = local.redis_password  # Пароль для подключения к Redis
    maxmemory_policy = "ALLKEYS_LRU"  # Политика очистки памяти: удаляются наименее используемые ключи
    version          = "7.2"  # Версия Redis
  }

  resources {
    resource_preset_id = "hm3-c2-m8"  # Тип конфигурации по CPU и памяти
    disk_type_id       = "network-ssd"  # Тип диска
    disk_size          = 65  # Размер диска в ГБ
  }

  host {
    zone      = "ru-central1-a"  # Зона доступности
    subnet_id = yandex_vpc_subnet.sentry-a.id  # ID подсети
  }
}

# Вывод внешних параметров подключения к Redis
output "externalRedis" {
  value = {
    host     = yandex_mdb_redis_cluster.sentry.host[0].fqdn  # FQDN первого хоста Redis
    port     = 6379  # Порт подключения Redis
    password = local.redis_password  # Пароль подключения
  }
  sensitive = true  # Значение помечено как чувствительное
}
