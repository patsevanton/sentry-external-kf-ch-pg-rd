# Создание кластера PostgreSQL в Yandex Cloud
resource "yandex_mdb_postgresql_cluster" "postgresql_cluster" {
  # Название кластера
  name                = "sentry"

  # Среда, в которой развертывается кластер
  environment         = "PRODUCTION"

  # Сеть, в которой будет размещен кластер
  network_id          = yandex_vpc_network.sentry.id

  # Конфигурация кластера PostgreSQL
  config {
    # Версия PostgreSQL
    version = "15" # TODO поменять на 16

    # Включение автофейловера (автоматический перевод на другой узел при сбое)
    autofailover = true

    # Период хранения резервных копий в днях
    backup_retain_period_days = 7

    resources {
      # Размер диска в ГБ
      disk_size          = 129

      # Тип диска
      disk_type_id       = "network-ssd"

      # Предустановленные ресурсы для кластера
      resource_preset_id = "s3-c2-m8"
    }
  }

  # Хост в зоне "ru-central1-a"
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.sentry-a.id
  }

  # Хост в зоне "ru-central1-b"
  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.sentry-b.id
  }

  # Хост в зоне "ru-central1-d"
  host {
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.sentry-d.id
  }
}

# Создание базы данных в PostgreSQL
resource "yandex_mdb_postgresql_database" "postgresql_database" {
  # Идентификатор кластера, к которому относится база данных
  cluster_id = yandex_mdb_postgresql_cluster.postgresql_cluster.id

  # Имя базы данных
  name       = "sentry"

  # Владелец базы данных (пользователь)
  owner      = yandex_mdb_postgresql_user.postgresql_user.name

  # Установка расширений для базы данных
  extension {
    # Расширение для работы с типом данных citext (регистр не учитывается при сравнении строк)
    name = "citext"
  }

  # Зависимость от ресурса пользователя
  depends_on = [yandex_mdb_postgresql_user.postgresql_user]
}

# Создание пользователя PostgreSQL
resource "yandex_mdb_postgresql_user" "postgresql_user" {
  # Идентификатор кластера, к которому принадлежит пользователь
  cluster_id = yandex_mdb_postgresql_cluster.postgresql_cluster.id

  # Имя пользователя
  name       = "sentry"

  # Пароль пользователя
  password   = local.postgres_password

  # Ограничение по количеству соединений
  conn_limit = 50 # TODO увеличить conn_limit

  # Разрешения для пользователя (пока пустой список)
  grants     = []
}

# Вывод внешних данных для подключения к базе данных PostgreSQL
output "externalPostgresql" {
  value = {
    # Пароль для подключения (значение скрыто)
    password = local.postgres_password

    # Адрес хоста для подключения (с динамическим именем хоста на основе ID кластера)
    host     = "c-${yandex_mdb_postgresql_cluster.postgresql_cluster.id}.rw.mdb.yandexcloud.net"

    # Порт для подключения к базе данных
    port     = 6432

    # Имя пользователя для подключения
    username = yandex_mdb_postgresql_user.postgresql_user.name

    # Имя базы данных для подключения
    database = yandex_mdb_postgresql_database.postgresql_database.name
  }
  # Помечаем значение как чувствительное (не выводить в логах)
  sensitive = true
}
