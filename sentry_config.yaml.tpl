user:
  password: "${user_password}"
  email: "${user_email}"
system:
  url: "${system_url}"
nginx:
  enabled: ${nginx_enabled}
ingress:
  enabled: ${ingress_enabled}
  hostname: "${ingress_hostname}"
  ingressClassName: "${ingress_class_name}"
  regexPathStyle: "${ingress_regex_path_style}"
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "${ingress_annotations.proxy_body_size}"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "${ingress_annotations.proxy_buffers_number}"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "${ingress_annotations.proxy_buffer_size}"
postgresql:
  enabled: ${postgresql_enabled}
externalPostgresql:
  password: "${external_postgresql.password}"
  host: "${external_postgresql.host}"
  port: ${external_postgresql.port}
  username: "${external_postgresql.username}"
  database: "${external_postgresql.database}"
redis:
  enabled: ${redis_enabled}
externalRedis:
  password: "${external_redis.password}"
  host: "${external_redis.host}"
  port: ${external_redis.port}
externalKafka:
  cluster:
%{ for kafka_host in external_kafka.cluster ~}
    - host: "${kafka_host.host}"
      port: ${kafka_host.port}
%{ endfor }
  sasl:
    mechanism: "${external_kafka.sasl.mechanism}"
    username: "${external_kafka.sasl.username}"
    password: "${external_kafka.sasl.password}"
  security:
    protocol: "${external_kafka.security.protocol}"
kafka:
  enabled: ${kafka_enabled}
zookeeper:
  enabled: ${zookeeper_enabled}
clickhouse:
  enabled: ${clickhouse_enabled}
externalClickhouse:
  password: "${external_clickhouse.password}"
  host: "${external_clickhouse.host}"
  database: "${external_clickhouse.database}"
  httpPort: ${external_clickhouse.httpPort}
  tcpPort: ${external_clickhouse.tcpPort}
  username: "${external_clickhouse.username}"
