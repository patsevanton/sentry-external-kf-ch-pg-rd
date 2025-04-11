resource "null_resource" "write_sentry_config" {
  provisioner "local-exec" {
    command = "echo '${local.sentry_config}' > sentry_config.yaml"
  }

  triggers = {
    sentry_config = local.sentry_config
  }
}


locals {
  sentry_config = templatefile("sentry_config.yaml.tpl", {
    sentry_admin_password  = local.sentry_admin_password # todo use random password
    user_email     = "admin@sentry.apatsev.org.ru"
    system_url     = "http://sentry.apatsev.org.ru"
    nginx_enabled  = false
    ingress_enabled = true
    ingress_hostname = "sentry.apatsev.org.ru"
    ingress_class_name = "nginx"
    ingress_regex_path_style = "nginx"
    ingress_annotations = {
      proxy_body_size = "200m"
      proxy_buffers_number = "16"
      proxy_buffer_size = "32k"
    }
    filestore = {
      s3 = {
        accessKey = yandex_storage_bucket.filestore.access_key
        secretKey  = yandex_storage_bucket.filestore.secret_key
        bucketName  = yandex_storage_bucket.filestore.bucket
      }
    }
    nodestore = {
      s3 = {
        accessKey = yandex_storage_bucket.nodestore.access_key
        secretKey  = yandex_storage_bucket.nodestore.secret_key
        bucketName  = yandex_storage_bucket.nodestore.bucket
      }
    }
    postgresql_enabled = false
    external_postgresql = {
      password = local.postgres_password
      host     = "c-${yandex_mdb_postgresql_cluster.postgresql_cluster.id}.rw.mdb.yandexcloud.net"
      port     = 6432
      username = yandex_mdb_postgresql_user.postgresql_user.name
      database = yandex_mdb_postgresql_database.postgresql_database.name
    }
    redis_enabled = false
    external_redis = {
      password = local.redis_password
      host     = yandex_mdb_redis_cluster.sentry.host[0].fqdn
      port     = 6380
    }
    external_kafka = {
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
    kafka_enabled = false
    zookeeper_enabled = false
    clickhouse_enabled = false
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
