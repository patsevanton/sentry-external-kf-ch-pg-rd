# Создание кластера ClickHouse в Яндекс Облаке
resource "yandex_mdb_clickhouse_cluster" "sentry" {
  folder_id   = local.folder_id                # ID папки в Yandex Cloud
  name        = "sentry"                       # Название кластера
  environment = "PRODUCTION"                   # Окружение (может быть также PRESTABLE)
  network_id  = yandex_vpc_network.sentry.id   # ID VPC-сети
  version     = 24.8                           # Версия ClickHouse

  clickhouse {
    resources {
      resource_preset_id = "s3-c2-m8"          # Пресет ресурсов для узлов ClickHouse
      disk_type_id       = "network-ssd"       # Тип диска
      disk_size          = 70                  # Размер диска в ГБ
    }
  }

  zookeeper {
    resources {
      resource_preset_id = "s3-c2-m8"          # Пресет ресурсов для узлов ZooKeeper
      disk_type_id       = "network-ssd"       # Тип диска
      disk_size          = 34                  # Размер диска в ГБ
    }
  }

  database {
    name = "sentry"                            # Имя базы данных в ClickHouse
  }

  user {
    name     = local.clickhouse_user           # Имя пользователя для доступа
    password = local.clickhouse_password       # Пароль пользователя
    permission {
      database_name = "sentry"                 # Назначение прав доступа к БД "sentry"
    }
  }

  # Добавление хостов ClickHouse и ZooKeeper с привязкой к подсетям
  host {
    type      = "CLICKHOUSE"                   # Тип узла — ClickHouse
    zone      = yandex_vpc_subnet.sentry-a.zone
    subnet_id = yandex_vpc_subnet.sentry-a.id  # Подсеть в зоне A
  }

  # Три узла ZooKeeper в разных зонах для отказоустойчивости
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

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
  
}

# Вывод конфиденциальной информации о ClickHouse-кластере
output "externalClickhouse" {
  value = {
    host     = yandex_mdb_clickhouse_cluster.sentry.host[0].fqdn     # FQDN первого ClickHouse-хоста
    database = one(yandex_mdb_clickhouse_cluster.sentry.database[*].name) # Имя БД
    httpPort = 8123                                                  # HTTP порт ClickHouse
    tcpPort  = 9000                                                  # TCP порт ClickHouse
    username = local.clickhouse_user                                 # Имя пользователя
    password = local.clickhouse_password                             # Пароль пользователя
  }
  sensitive = true                                                   # Отметка, что output содержит чувствительные данные
}
