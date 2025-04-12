# Ресурс null_resource используется для выполнения локальной команды,
# генерирующей файл конфигурации Sentry на основе шаблона
resource "null_resource" "write_sentry_config" {
  provisioner "local-exec" {
    # Команда записывает сгенерированную строку (YAML) в файл values_sentry.yaml
    command = "echo '${local.sentry_config}' > values_sentry.yaml"
  }

  triggers = {
    # Триггер перезапуска ресурса при изменении содержимого values_sentry.yaml.tpl
    sentry_config = local.sentry_config
  }
}

locals {
  # Локальная переменная с конфигурацией Sentry, генерируемая из шаблона values_sentry.yaml.tpl
  sentry_config = templatefile("values_sentry.yaml.tpl", {
    # Пароль администратора Sentry
    sentry_admin_password  = local.sentry_admin_password

    # Email пользователя-администратора
    user_email     = "admin@sentry.apatsev.org.ru"

    # URL системы Sentry
    system_url     = "http://sentry.apatsev.org.ru" # TODO использовать переменную

    # Включение/отключение Nginx
    nginx_enabled  = false

    # Использование Ingress для доступа к Sentry
    ingress_enabled = true

    # Имя хоста, используемого Ingress
    ingress_hostname = "sentry.apatsev.org.ru" # использовать переменную и конкатенацию

    # Имя класса Ingress-контроллера
    ingress_class_name = "nginx"

    # Стиль регулярных путей в Ingress
    ingress_regex_path_style = "nginx"

    # Аннотации Ingress для настройки nginx
    ingress_annotations = {
      proxy_body_size = "200m"          # Максимальный размер тела запроса
      proxy_buffers_number = "16"       # Количество буферов
      proxy_buffer_size = "32k"         # Размер каждого буфера
    }

    # Настройки S3-хранилища для файлового хранилища (filestore)
    filestore = {
      s3 = {
        accessKey = yandex_storage_bucket.filestore.access_key
        secretKey  = yandex_storage_bucket.filestore.secret_key
        bucketName  = yandex_storage_bucket.filestore.bucket
      }
    }

    # Настройки S3-хранилища для хранения событий (nodestore)
    nodestore = {
      s3 = {
        accessKey = yandex_storage_bucket.nodestore.access_key
        secretKey  = yandex_storage_bucket.nodestore.secret_key
        bucketName  = yandex_storage_bucket.nodestore.bucket
      }
    }

    # Отключение встроенного PostgreSQL, использование внешнего
    postgresql_enabled = false

    # Настройки подключения к внешнему PostgreSQL
    external_postgresql = {
      password = local.postgres_password
      host     = "c-${yandex_mdb_postgresql_cluster.postgresql_cluster.id}.rw.mdb.yandexcloud.net"
      port     = 6432
      username = yandex_mdb_postgresql_user.postgresql_user.name
      database = yandex_mdb_postgresql_database.postgresql_database.name
    }

    # Отключение встроенного Redis, использование внешнего
    redis_enabled = false

    # Настройки подключения к внешнему Redis
    external_redis = {
      password = local.redis_password
      host     = "c-${yandex_mdb_redis_cluster.sentry.id}.rw.mdb.yandexcloud.net"
      port     = 6380 # 6380 — если используется SSL, иначе 6379
    }

    # Настройки внешнего Kafka
    external_kafka = {
      cluster = [
        # Получение всех узлов Kafka с ролью "KAFKA"
        for host in yandex_mdb_kafka_cluster.sentry.host : {
          host = host.name
          port = 9091 # 9091 — если используется SSL, иначе 9092
        } if host.role == "KAFKA"
      ]

      # Настройки аутентификации SASL
      sasl = {
        mechanism = "SCRAM-SHA-512"
        username  = local.kafka_user
        password  = local.kafka_password
      }

      # Настройки безопасности Kafka
      security = {
        protocol = "SASL_SSL" # Использовать SASL_SSL (или SASL_PLAINTEXT при отсутствии SSL)
      }
    }

    # Отключение встроенного Kafka
    kafka_enabled = false

    # Отключение встроенного Zookeeper
    zookeeper_enabled = false

    # Отключение встроенного Clickhouse, использование внешнего
    clickhouse_enabled = false

    # Настройки подключения к внешнему Clickhouse
    external_clickhouse = {
      password = local.clickhouse_password
      host     = yandex_mdb_clickhouse_cluster.sentry.host[0].fqdn
      database = one(yandex_mdb_clickhouse_cluster.sentry.database[*].name)
      httpPort = 8123
      tcpPort  = 9000
      username = local.clickhouse_user
    }
  })
}
