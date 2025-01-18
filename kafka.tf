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

resource "yandex_mdb_kafka_user" "sentry" {
  cluster_id = yandex_mdb_kafka_cluster.sentry.id
  name       = local.kafka_user
  password   = local.kafka_password

  dynamic "permission" {
    for_each = toset([
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
    ])

    content {
      topic_name = permission.value
      role       = "ACCESS_ROLE_CONSUMER"
    }
  }

  dynamic "permission" {
    for_each = toset([
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
    ])

    content {
      topic_name = permission.value
      role       = "ACCESS_ROLE_PRODUCER"
    }
  }
}

resource "yandex_mdb_kafka_topic" "events" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "events"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "event-replacements" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "event-replacements"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "cdc" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "cdc"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "transactions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "transactions"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-transactions-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-transactions-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-metrics"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "outcomes" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "outcomes"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "outcomes-billing" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "outcomes-billing"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-sessions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-sessions"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-sessions-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-sessions-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-metrics-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-metrics-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-events" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-events"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-transactions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-transactions"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-sessions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-sessions"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-metrics"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-generic-metrics-sets" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-generic-metrics-sets"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-generic-metrics-distributions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-generic-metrics-distributions"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-generic-metrics-counters" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-generic-metrics-counters"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "events-subscription-results" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "events-subscription-results"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "transactions-subscription-results" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "transactions-subscription-results"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "sessions-subscription-results" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "sessions-subscription-results"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "metrics-subscription-results" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "metrics-subscription-results"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "generic-metrics-subscription-results" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "generic-metrics-subscription-results"
  partitions         = 1
  replication_factor = 1
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-queries" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-queries"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "processed-profiles" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "processed-profiles"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "profiles-call-tree" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "profiles-call-tree"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-replay-events" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-replay-events"
  partitions         = 1
  replication_factor = 1
  topic_config {
    # max_message_bytes = "15000000"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-generic-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-generic-metrics"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-generic-metrics-sets-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-generic-metrics-sets-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-generic-metrics-distributions-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-generic-metrics-distributions-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-generic-metrics-counters-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-generic-metrics-counters-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "generic-events" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "generic-events"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-generic-events-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-generic-events-commit-log"
  partitions         = 1
  replication_factor = 1
  topic_config {
    cleanup_policy        = "CLEANUP_POLICY_COMPACT_AND_DELETE"
    min_compaction_lag_ms = "3600000"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "group-attributes" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "group-attributes"
  partitions         = 1
  replication_factor = 1
  topic_config {
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-attribution" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-attribution"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-metrics"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-sessions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-sessions"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-generic-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-generic-metrics"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-replays" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-replays"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-generic-events" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-generic-events"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-querylog" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-querylog"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-dead-letter-group-attributes" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-dead-letter-group-attributes"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-attachments" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-attachments"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-transactions" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-transactions"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-events" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-events"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-replay-recordings" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-replay-recordings"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-metrics"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-performance-metrics" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-performance-metrics"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-monitors" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-monitors"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "profiles" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "profiles"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "ingest-occurrences" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "ingest-occurrences"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-spans" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-spans"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "shared-resources-usage" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "shared-resources-usage"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-metrics-summaries" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-metrics-summaries"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "scheduled-subscriptions-generic-metrics-gauges" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "scheduled-subscriptions-generic-metrics-gauges"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-profile-chunks" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-profile-chunks"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "yandex_mdb_kafka_topic" "snuba-generic-metrics-gauges-commit-log" {
  cluster_id         = yandex_mdb_kafka_cluster.sentry.id
  name               = "snuba-generic-metrics-gauges-commit-log"
  partitions         = 1
  replication_factor = 1

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}