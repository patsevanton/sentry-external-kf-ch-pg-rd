# Пользовательская конфигурация для Sentry
user:
  password: "${sentry_admin_password}"  # Пароль администратора Sentry
  email: "${user_email}"                # Email администратора

# Системная информация
system:
  url: "${system_url}"  # URL-адрес системы

# Контейнерные образы компонентов Sentry
images:
  sentry:
    repository: ghcr.io/patsevanton/ghcr-sentry-custom-images  # Кастомный образ Sentry
  snuba:
    repository: ghcr.io/patsevanton/ghcr-snuba-custom-images   # Кастомный образ Snuba
  relay:
    repository: ghcr.io/patsevanton/ghcr-relay-custom-images   # Кастомный образ Relay

# Настройка NGINX
nginx:
  enabled: ${nginx_enabled}  # Включен ли встроенный NGINX

# Настройка ingress-контроллера
ingress:
  enabled: ${ingress_enabled}                     # Включение ingress
  hostname: "${ingress_hostname}"                 # Хостнейм для доступа
  ingressClassName: "${ingress_class_name}"       # Класс ingress-контроллера
  regexPathStyle: "${ingress_regex_path_style}"   # Использование регулярных выражений в путях
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "${ingress_annotations.proxy_body_size}"  # Максимальный размер тела запроса
    nginx.ingress.kubernetes.io/proxy-buffers-number: "${ingress_annotations.proxy_buffers_number}"  # Количество буферов
    nginx.ingress.kubernetes.io/proxy-buffer-size: "${ingress_annotations.proxy_buffer_size}"        # Размер буфера

# Настройки файлового хранилища
filestore:
  backend: "s3"
  s3:
    accessKey: "${filestore.s3.accessKey}"
    secretKey: "${filestore.s3.secretKey}"
    region_name: ru-central1
    bucketName: "${filestore.s3.bucketName}"
    endpointUrl: "https://storage.yandexcloud.net"
    location: "debug-files" # https://docs.sentry.io/platforms/android/data-management/debug-files/
config:
  sentryConfPy: |
    SENTRY_NODESTORE = "sentry_s3_nodestore.backend.S3NodeStorage"
    SENTRY_NODESTORE_OPTIONS = {
        "bucket_name": "${nodestore.s3.bucketName}",
        "region": "ru-central1",
        "endpoint": "https://storage.yandexcloud.net",
        "aws_access_key_id": "${nodestore.s3.accessKey}",
        "aws_secret_access_key": "${nodestore.s3.secretKey}",
    }
postgresql:
  enabled: ${postgresql_enabled}
externalPostgresql:
  password: "${external_postgresql.password}"
  host: "${external_postgresql.host}"
  port: ${external_postgresql.port}
  username: "${external_postgresql.username}"
  database: "${external_postgresql.database}"
  sslMode: require
redis:
  enabled: ${redis_enabled}
externalRedis:
  password: "${external_redis.password}"
  host: "${external_redis.host}"
  port: ${external_redis.port}
  ssl: true
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
