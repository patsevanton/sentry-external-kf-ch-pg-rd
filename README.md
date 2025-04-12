# **"Sentry с внешними Kafka, ClickHouse, Postgres, Redis (и немного Terraform магии)"**

## В этом посте

- Кратко о Sentry: что это, зачем он нужен
- Почему важно выносить Kafka, Redis, ClickHouse, Postgres вне Kubernetes
- Подключение Kafka, Redis, ClickHouse, Postgres через SSL
- Структура Terraform проекта
- Хранение debug файлов и основных данных (Nodestore) в S3
- Динамическое формирование файла values.yaml
- Планы на будущие посты о Sentry

### Кратко о Sentry: что это, зачем он нужен

**Sentry** — это инструмент для отслеживания ошибок и производительности приложений в реальном времени.

- Отслеживает баги и exceptions в бекенд, веб и мобильных приложениях.
- Показывает стек вызовов, контекст, окружение, пользователя и другую полезную информацию.
- Помогает разработчикам быстро находить и исправлять баги.
- Поддерживает множество языков и фреймворков

## Почему важно выносить Kafka, Redis, ClickHouse, Postgres вне Kubernetes
Плюсы такого подхода:

* Масштабируемость
* Изоляция ресурсов
* Более надежное хранилище

Минусы/предостережения:

* Логирование и трассировка проблем становится чуть сложнее
* Требует аккуратной настройки переменных и IAM-доступов (особенно к S3)

## Подключение Kafka, Redis, ClickHouse, Postgres через SSL
В этом посте в отличие от предыдущего будет подключение Kafka, Redis, Postgres через SSL.
Для подключения ClickHouse по SSL ждем вот этого [PR](https://github.com/sentry-kubernetes/charts/pull/1671).

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

## Хранение основных данных (Nodestore) в S3
Отмечу отдельно что основные данные (Nodestore) хранятся в S3
Файл `s3_nodestore.tf` — хранилище blob-данных managed S3 (Yandex Cloud)
В файле sentry_config.yaml указание где хранить Nodestore указывается так
```
sentryConfPy: |
  SENTRY_NODESTORE = "sentry_s3_nodestore.backend.S3NodeStorage"
  SENTRY_NODESTORE_OPTIONS = {
      "bucket_name": "название-бакета",
      "region": "ru-central1",
      "endpoint": "https://storage.yandexcloud.net",
      "aws_access_key_id": "aws_access_key_id",
      "aws_secret_access_key": "aws_secret_access_key",
  }
```

## Формирование values.yaml для Sentry

- Файл values.yaml (`sentry_config.yaml`) формируется используя шаблон `sentry_config.yaml.tpl` и `templatefile.tf`
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

Формируем kubeconfig для кластера k8s с указанным ID (xx) в Yandex Cloud, используя внешний IP (--external)
```shell
yc managed-kubernetes cluster get-credentials --id xxx --external --force
```

Проверяем сгенерированный конфиг sentry_config.yaml из шаблона

Деплоим Sentry в кластер через Helm
```shell
kubectl create namespace test
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm upgrade --install sentry -n test sentry/sentry --version 26.15.1 -f sentry_config.yaml
```

