# Получаем информацию о конфигурации клиента Yandex
data "yandex_client_config" "client" {}

# Генерация случайного пароля для Kafka
resource "random_password" "kafka" {
  length      = 20            # Длина пароля 20 символов
  special     = false          # Без специальных символов
  min_numeric = 4             # Минимум 4 цифры в пароле
  min_upper   = 4             # Минимум 4 заглавные буквы в пароле
}

# Генерация случайного пароля для ClickHouse
resource "random_password" "clickhouse" {
  length      = 20            # Длина пароля 20 символов
  special     = false          # Без специальных символов
  min_numeric = 4             # Минимум 4 цифры в пароле
  min_upper   = 4             # Минимум 4 заглавные буквы в пароле
}

# Генерация случайного пароля для Redis
resource "random_password" "redis" {
  length      = 20            # Длина пароля 20 символов
  special     = false          # Без специальных символов
  min_numeric = 4             # Минимум 4 цифры в пароле
  min_upper   = 4             # Минимум 4 заглавные буквы в пароле
}

# Генерация случайного пароля для PostgreSQL
resource "random_password" "postgres" {
  length      = 20            # Длина пароля 20 символов
  special     = false          # Без специальных символов
  min_numeric = 4             # Минимум 4 цифры в пароле
  min_upper   = 4             # Минимум 4 заглавные буквы в пароле
}

# Генерация случайного пароля для администратора Sentry
resource "random_password" "sentry_admin_password" {
  length      = 20            # Длина пароля 20 символов
  special     = false          # Без специальных символов
  min_numeric = 4             # Минимум 4 цифры в пароле
  min_upper   = 4             # Минимум 4 заглавные буквы в пароле
}

# Локальные переменные для настройки инфраструктуры
locals {
  folder_id           = data.yandex_client_config.client.folder_id  # ID папки в Yandex Cloud
  sentry_admin_password = random_password.sentry_admin_password.result # Сгенерированный пароль администратора Sentry
  kafka_user          = "sentry"                                    # Имя пользователя для Kafka
  kafka_password      = random_password.kafka.result                # Сгенерированный пароль для Kafka
  clickhouse_user     = "sentry"                                    # Имя пользователя для ClickHouse
  clickhouse_password = random_password.clickhouse.result          # Сгенерированный пароль для ClickHouse
  redis_password      = random_password.redis.result                # Сгенерированный пароль для Redis
  postgres_password   = random_password.postgres.result             # Сгенерированный пароль для PostgreSQL
  filestore_bucket    = "sentry-bucket-apatsev-filestore-test"      # Имя бакета для Filestore
  nodestore_bucket    = "sentry-bucket-apatsev-nodestore-test"      # Имя бакета для Nodestore
}

# Выводим сгенерированные пароли для сервисов
output "generated_passwords" {
  description = "Map of generated passwords for services"  # Описание вывода
  value = {
    kafka_password      = random_password.kafka.result      # Пароль для Kafka
    clickhouse_password = random_password.clickhouse.result # Пароль для ClickHouse
    redis_password      = random_password.redis.result      # Пароль для Redis
    postgres_password   = random_password.postgres.result   # Пароль для PostgreSQL
  }
  sensitive = true  # Скрывает пароли в логах, но они доступны через `terraform output`
}
