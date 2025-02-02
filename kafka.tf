resource "yandex_mdb_kafka_cluster" "sentry" {
  folder_id   = local.folder_id
  name        = "sentry"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.sentry.id
  subnet_ids = [
    yandex_vpc_subnet.sentry-a.id,
    yandex_vpc_subnet.sentry-b.id,
    yandex_vpc_subnet.sentry-d.id
  ]

  config {
    version       = "2.8"
    brokers_count = 1
    zones = [
      yandex_vpc_subnet.sentry-a.zone,
      yandex_vpc_subnet.sentry-b.zone,
      yandex_vpc_subnet.sentry-d.zone
    ]
    assign_public_ip = false
    schema_registry  = false
    kafka {
      resources {
        resource_preset_id = "s2.micro" # s3-c2-m8
        disk_type_id       = "network-ssd"
        disk_size          = 200
      }
    }
  }
}

locals {
  kafka_topics = {
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

resource "yandex_mdb_kafka_topic" "topics" {
  for_each = local.kafka_topics

  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = each.key
  partitions         = 1
  replication_factor = 1

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

locals {
  kafka_permissions = keys(local.kafka_topics)
}

resource "yandex_mdb_kafka_user" "sentry" {
  cluster_id = yandex_mdb_kafka_cluster.sentry.id
  name       = local.kafka_user
  password   = local.kafka_password

  dynamic "permission" {
    for_each = toset(local.kafka_permissions)

    content {
      topic_name = permission.value
      role       = "ACCESS_ROLE_CONSUMER"
    }
  }

  dynamic "permission" {
    for_each = toset(local.kafka_permissions)

    content {
      topic_name = permission.value
      role       = "ACCESS_ROLE_PRODUCER"
    }
  }
}

output "externalKafka" {
  description = "Kafka connection details in structured format"
  value = {
    cluster = [
      for host in yandex_mdb_kafka_cluster.sentry.host : {
        host = host.name
        port = 9092
      } if host.role == "KAFKA"
    ]
    sasl = {
      mechanism = "SCRAM-SHA-512"
      username  = local.kafka_user
      password  = local.kafka_password
    }
    security = {
      protocol = "SASL_PLAINTEXT"
    }
  }
}
