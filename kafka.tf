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
    "outcomes-billing" = {},
    "ingest-sessions" = {},
    "snuba-sessions-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "snuba-metrics-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "scheduled-subscriptions-events" = {},
    "scheduled-subscriptions-transactions" = {},
    "scheduled-subscriptions-sessions" = {},
    "scheduled-subscriptions-metrics" = {},
    "scheduled-subscriptions-generic-metrics-sets" = {},
    "scheduled-subscriptions-generic-metrics-distributions" = {},
    "scheduled-subscriptions-generic-metrics-counters" = {},
    "events-subscription-results" = {},
    "transactions-subscription-results" = {},
    "sessions-subscription-results" = {},
    "metrics-subscription-results" = {},
    "generic-metrics-subscription-results" = {},
    "snuba-queries" = {},
    "processed-profiles" = {},
    "profiles-call-tree" = {},
    "ingest-replay-events" = {},
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
    "generic-events" = {},
    "snuba-generic-events-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    },
    "group-attributes" = {},
    "snuba-attribution" = {},
    "snuba-dead-letter-metrics" = {},
    "snuba-dead-letter-sessions" = {},
    "snuba-dead-letter-generic-metrics" = {},
    "snuba-dead-letter-replays" = {},
    "snuba-dead-letter-generic-events" = {},
    "snuba-dead-letter-querylog" = {},
    "snuba-dead-letter-group-attributes" = {},
    "ingest-attachments" = {},
    "ingest-transactions" = {},
    "ingest-events" = {},
    "ingest-replay-recordings" = {},
    "ingest-metrics" = {},
    "ingest-performance-metrics" = {},
    "ingest-monitors" = {},
    "profiles" = {},
    "ingest-occurrences" = {},
    "snuba-spans" = {},
    "shared-resources-usage" = {},
    "snuba-metrics-summaries" = {},
    "scheduled-subscriptions-generic-metrics-gauges" = {},
    "snuba-profile-chunks" = {},
    "snuba-generic-metrics-gauges-commit-log" = {
      cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
      min_compaction_lag_ms = "3600000"
    }
  }
}

resource "yandex_mdb_kafka_topic" "topics" {
  for_each = local.kafka_topics

  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = each.key
  partitions         = 1
  replication_factor = 1

  dynamic "topic_config" {
    for_each = each.value != {} ? [1] : []
    content {
      cleanup_policy        = each.value.cleanup_policy
      min_compaction_lag_ms = each.value.min_compaction_lag_ms
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

locals {
  kafka_permissions = [
    "cdc",
    "event-replacements",
    "events",
    "events-subscription-results",
    "generic-events",
    "generic-metrics-subscription-results",
    "group-attributes",
    "ingest-attachments",
    "ingest-events",
    "ingest-metrics",
    "ingest-monitors",
    "ingest-occurrences",
    "ingest-performance-metrics",
    "ingest-replay-events",
    "ingest-replay-recordings",
    "ingest-sessions",
    "ingest-transactions",
    "metrics-subscription-results",
    "outcomes",
    "outcomes-billing",
    "processed-profiles",
    "profiles",
    "profiles-call-tree",
    "scheduled-subscriptions-events",
    "scheduled-subscriptions-generic-metrics-counters",
    "scheduled-subscriptions-generic-metrics-distributions",
    "scheduled-subscriptions-generic-metrics-sets",
    "scheduled-subscriptions-metrics",
    "scheduled-subscriptions-sessions",
    "scheduled-subscriptions-transactions",
    "sessions-subscription-results",
    "shared-resources-usage",
    "snuba-attribution",
    "snuba-commit-log",
    "snuba-dead-letter-generic-events",
    "snuba-dead-letter-generic-metrics",
    "snuba-dead-letter-group-attributes",
    "snuba-dead-letter-metrics",
    "snuba-dead-letter-querylog",
    "snuba-dead-letter-replays",
    "snuba-dead-letter-sessions",
    "snuba-generic-events-commit-log",
    "snuba-generic-metrics",
    "snuba-generic-metrics-counters-commit-log",
    "snuba-generic-metrics-distributions-commit-log",
    "snuba-generic-metrics-sets-commit-log",
    "snuba-metrics",
    "snuba-metrics-commit-log",
    "snuba-metrics-summaries",
    "snuba-queries",
    "snuba-sessions-commit-log",
    "snuba-spans",
    "snuba-transactions-commit-log",
    "transactions",
    "transactions-subscription-results",
    "scheduled-subscriptions-generic-metrics-gauges",
    "snuba-profile-chunks",
    "snuba-generic-metrics-gauges-commit-log",
  ]
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
