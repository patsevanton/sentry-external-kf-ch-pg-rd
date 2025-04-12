# **"Sentry с внешними Kafka, ClickHouse, Postgres, Redis (и немного Terraform магии)"**

## В этом посте

- Кратко о Sentry: что это, зачем он нужен
- Почему важно выносить Kafka, Redis, ClickHouse, Postgres вне Kubernetes
- Подключение Kafka, Redis, ClickHouse, Postgres через SSL
- Хранение debug файлов и основных данных (Nodestore) в S3
- Динамическое формирование файла values.yaml
- Планы на будущие посты о Sentry

### Зачем нужен:

**Sentry** — это инструмент для отслеживания ошибок и производительности приложений в реальном времени.

- Отслеживает баги и exceptions в бекенд, веб и мобильных приложениях.
- Показывает стек вызовов, контекст, окружение, пользователя и другую полезную информацию.
- Помогает разработчикам быстро находить и исправлять баги.
- Поддерживает множество языков и фреймворков


## Структура Terraform проекта

- Список и краткое описание ключевых файлов:
    - `clickhouse.tf` — managed ClickHouse (Yandex Cloud)
    - `kafka.tf` — managed Kafka (Yandex Cloud)
    - `postgres.tf` — managed Postgres (Yandex Cloud)
    - `redis.tf` — для кэширования и очередей managed Redis (Yandex Cloud)
    - `s3_filestore.tf` и `s3_nodestore.tf` — хранилище blob-данных managed S3 (Yandex Cloud)
    - `sentry_config.yaml` и `sentry_config.yaml.tpl` — конфиг для Sentry, параметризуем через Terraform `templatefile`
    - `k8s.tf` — managed Kuberbetes (Yandex Cloud) для деплоя Sentry
    - `example-python/` — демонстрация, как отправлять ошибки в Sentry из Python
    - `locals.tf` – определяет локальные переменные, используемые в других файлах Terraform.
    - `net.tf` – описывает сетевые ресурсы, такие как VPC, подсети и маршруты.
    - `ip-dns.tf` – настраивает IP-адреса и записи DNS для ресурсов.
    - `versions.tf` – задаёт версии Terraform и провайдеров, необходимых для работы проекта.


## Конфигурация Sentry

- Как конфигурируется Sentry через `sentry_config.yaml.tpl`
- Примеры параметров:
    - `SENTRY_REDIS_HOST`
    - `SENTRY_DB_NAME`
    - `KAFKA_BROKER_URL`
    - `SENTRY_EVENT_RETENTION_DAYS`
- Как шаблон превращается в финальный конфиг (через `templatefile()` в Terraform)


## Пример использования (`example-python`)

- Что лежит в `example-python/`
- Как подключить Sentry SDK
- Простой пример выброса exception’а:

## Как всё это собрать и запустить
Запускаем инфраструктуру:

```shell
export YC_FOLDER_ID='ваша подсеть'
terraform init
terraform apply
```
Проверяем выходные данные (terraform output)
Генерим конфиг sentry_config.yaml из шаблона
Деплоим Sentry в кластер через Helm


## Подводим итоги
Плюсы такого подхода:

* Масштабируемость
* Изоляция ресурсов
* Более надежное хранилище

Минусы/предостережения:

* Логирование и трассировка проблем становится чуть сложнее
* Требует аккуратной настройки переменных и IAM-доступов (особенно к S3)
