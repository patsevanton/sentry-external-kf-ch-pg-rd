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

# Встроенная PostgreSQL база данных
postgresql:
  enabled: ${postgresql_enabled}  # Использовать ли встроенный PostgreSQL

# Конфигурация внешней PostgreSQL базы данных
externalPostgresql:
  password: "${external_postgresql.password}"  # Пароль БД
  host: "${external_postgresql.host}"          # Хост БД
  port: ${external_postgresql.port}            # Порт
  username: "${external_postgresql.username}"  # Имя пользователя
  database: "${external_postgresql.database}"  # Название БД
  sslMode: require                              # Режим SSL

# Встроенный Redis
redis:
  enabled: ${redis_enabled}  # Включить ли встроенный Redis

# Подключение к внешнему Redis
externalRedis:
  password: "${external_redis.password}"  # Пароль Redis
  host: "${external_redis.host}"          # Хост Redis
  port: ${external_redis.port}            # Порт Redis
  ssl: true                               # Использовать SSL

# Внешний кластер Kafka
externalKafka:
  cluster:
%{ for kafka_host in external_kafka.cluster ~}
    - host: "${kafka_host.host}"         # Хост Kafka брокера
      port: ${kafka_host.port}           # Порт Kafka брокера
%{ endfor }
  sasl:
    mechanism: "${external_kafka.sasl.mechanism}"  # Механизм аутентификации (например, PLAIN, SCRAM)
    username: "${external_kafka.sasl.username}"    # Имя пользователя Kafka
    password: "${external_kafka.sasl.password}"    # Пароль Kafka
  security:
    protocol: "${external_kafka.security.protocol}"  # Протокол безопасности (например, SASL_SSL)

# Встроенный кластер Kafka
kafka:
  enabled: ${kafka_enabled}  # Включить встроенный Kafka

# Встроенный ZooKeeper
zookeeper:
  enabled: ${zookeeper_enabled}  # Включить встроенный ZooKeeper

# Встроенный Clickhouse
clickhouse:
  enabled: ${clickhouse_enabled}  # Включить встроенный Clickhouse

# Подключение к внешнему Clickhouse
externalClickhouse:
  password: "${external_clickhouse.password}"      # Пароль
  host: "${external_clickhouse.host}"              # Хост
  database: "${external_clickhouse.database}"      # Название БД
  httpPort: ${external_clickhouse.httpPort}        # HTTP-порт
  tcpPort: ${external_clickhouse.tcpPort}          # TCP-порт
  username: "${external_clickhouse.username}"      # Имя пользователя
