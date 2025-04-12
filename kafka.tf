# Создание Kafka-кластера в Yandex Cloud
# Здесь определяется Kafka кластер с именем "sentry" в Yandex Cloud с необходимыми параметрами конфигурации.
resource "yandex_mdb_kafka_cluster" "sentry" {
  folder_id   = local.folder_id                      # ID папки в Yandex Cloud
  name        = "sentry"                             # Имя кластера
  environment = "PRODUCTION"                         # Среда (может быть PRESTABLE/PRODUCTION)
  network_id  = yandex_vpc_network.sentry.id         # Сеть VPC, в которой будет размещён кластер

  subnet_ids = [                                     # Список подсетей в разных зонах доступности
    yandex_vpc_subnet.sentry-a.id,
    yandex_vpc_subnet.sentry-b.id,
    yandex_vpc_subnet.sentry-d.id
  ]

  config {
    version       = "3.5"                            # Версия Kafka
    brokers_count = 1                                # Кол-во брокеров в каждой зоне
    zones = [                                        # Зоны размещения брокеров
      yandex_vpc_subnet.sentry-a.zone,
      yandex_vpc_subnet.sentry-b.zone,
      yandex_vpc_subnet.sentry-d.zone
    ]
    assign_public_ip = false                         # Не присваивать публичный IP
    schema_registry  = false                         # Без поддержки Schema Registry

    kafka {
      resources {
        resource_preset_id = "s2.micro"              # Тип инстанса
        disk_type_id       = "network-ssd"           # Тип диска
        disk_size          = 200                     # Размер диска в ГБ
      }
    }
  }
}

# Список топиков Kafka с параметрами
# Переменная локальная, которая содержит все топики Kafka и их параметры.
locals {
  kafka_topics = {
    # Каждый ключ — имя топика. Значение — map опций конфигурации (может быть пустой)
    "events" = {},
    "event-replacements" = {},
    "snuba-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "cdc" = {},
    "transactions" = {},
    "snuba-transactions-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "snuba-metrics" = {},
    "outcomes" = {},
    "outcomes-dlq" = {},
    "outcomes-billing" = {},
    "outcomes-billing-dlq" = {},
    "ingest-sessions" = {},
    "snuba-metrics-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "scheduled-subscriptions-events" = {},
    "scheduled-subscriptions-transactions" = {},
    "scheduled-subscriptions-metrics" = {},
    "scheduled-subscriptions-generic-metrics-sets" = {},
    "scheduled-subscriptions-generic-metrics-distributions" = {},
    "scheduled-subscriptions-generic-metrics-counters" = {},
    "scheduled-subscriptions-generic-metrics-gauges" = {},
    "events-subscription-results" = {},
    "transactions-subscription-results" = {},
    "metrics-subscription-results" = {},
    "generic-metrics-subscription-results" = {},
    "snuba-queries" = {},
    "processed-profiles" = {},
    "profiles-call-tree" = {},
    "snuba-profile-chunks" = {},
    "ingest-replay-events" = {
      max_message_bytes     = "15000000"
    },
    "snuba-generic-metrics" = {},
    "snuba-generic-metrics-sets-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "snuba-generic-metrics-distributions-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "snuba-generic-metrics-counters-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "snuba-generic-metrics-gauges-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "generic-events" = {},
    "snuba-generic-events-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "group-attributes" = {},
    "snuba-dead-letter-metrics" = {},
    "snuba-dead-letter-generic-metrics" = {},
    "snuba-dead-letter-replays" = {},
    "snuba-dead-letter-generic-events" = {},
    "snuba-dead-letter-querylog" = {},
    "snuba-dead-letter-group-attributes" = {},
    "ingest-attachments" = {},
    "ingest-attachments-dlq" = {},
    "ingest-transactions" = {},
    "ingest-transactions-dlq" = {},
    "ingest-transactions-backlog" = {},
    "ingest-events" = {},
    "ingest-events-dlq" = {},
    "ingest-replay-recordings" = {},
    "ingest-metrics" = {},
    "ingest-metrics-dlq" = {},
    "ingest-performance-metrics" = {},
    "ingest-feedback-events" = {},
    "ingest-feedback-events-dlq" = {},
    "ingest-monitors" = {},
    "monitors-clock-tasks" = {},
    "monitors-clock-tick" = {},
    "monitors-incident-occurrences" = {},
    "profiles" = {},
    "ingest-occurrences" = {},
    "snuba-spans" = {},
    "snuba-eap-spans-commit-log" = {},
    "scheduled-subscriptions-eap-spans" = {},
    "eap-spans-subscription-results" = {},
    "snuba-eap-mutations" = {},
    "snuba-lw-deletions-generic-events" = {},
    "shared-resources-usage" = {},
    "buffered-segments" = {},
    "buffered-segments-dlq" = {},
    "uptime-configs" = {},
    "uptime-results" = {},
    "snuba-uptime-results" = {},
    "task-worker" = {},
    "snuba-ourlogs" = {}
  }
}

# Создание Kafka-топиков на основе описания в locals.kafka_topics
# Итерируем по списку топиков и создаём их в Kafka с конфигурациями.
resource "yandex_mdb_kafka_topic" "topics" {
  for_each = local.kafka_topics                      # Итерируемся по каждому топику

  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = each.key                      # Имя топика
  partitions         = 1                             # Кол-во партиций
  replication_factor = 1                             # Фактор репликации (можно увеличить для отказоустойчивости)

  topic_config {
    cleanup_policy        = lookup(each.value, "cleanup_policy", null)
    min_compaction_lag_ms = lookup(each.value, "min_compaction_lag_ms", null)
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# Локальная переменная со списком имен всех топиков (используется для прав доступа)
# Список всех имен топиков, используемых для назначения прав доступа.
locals {
  kafka_permissions = keys(local.kafka_topics)
}

# Создание пользователя Kafka и назначение прав доступа к каждому топику
# Создаём пользователя Kafka и настраиваем права доступа для консьюмера и продюсера.
resource "yandex_mdb_kafka_user" "sentry" {
  cluster_id = yandex_mdb_kafka_cluster.sentry.id
  name       = local.kafka_user                     # Имя пользователя
  password   = local.kafka_password                 # Пароль пользователя

  # Назначение роли "консьюмер" для каждого топика
  dynamic "permission" {
    for_each = toset(local.kafka_permissions)
    content {
      topic_name = permission.value
      role       = "ACCESS_ROLE_CONSUMER"
    }
  }

  # Назначение роли "продюсер" для каждого топика
  dynamic "permission" {
    for_each = toset(local.kafka_permissions)
    content {
      topic_name = permission.value
      role       = "ACCESS_ROLE_PRODUCER"
    }
  }
}

# Вывод Kafka-подключения в виде структурированных данных (sensitive — чувствительные данные скрываются)
# Данный вывод предоставляет информацию о подключении к Kafka с учётом безопасности.
output "externalKafka" {
  description = "Kafka connection details in structured format"
  value = {
    cluster = [
      for host in yandex_mdb_kafka_cluster.sentry.host : {
        host = host.name
        port = 9091 # 9091 — если используется SSL, иначе 9092
      } if host.role == "KAFKA"
    ]
    sasl = {
      mechanism = "SCRAM-SHA-512" # Механизм аутентификации (например, PLAIN, SCRAM)
      username  = local.kafka_user
      password  = local.kafka_password
    }
    security = {
      protocol = "SASL_SSL" # Использовать SASL_SSL (или SASL_PLAINTEXT при отсутствии SSL)
    }
  }
  sensitive = true
}
