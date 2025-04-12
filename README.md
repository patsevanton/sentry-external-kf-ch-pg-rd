# **"Sentry с внешними Kafka, ClickHouse, Postgres, Redis и Nodestore в S3"**

## Кратко о Sentry: что это, зачем он нужен

**[Sentry](https://github.com/getsentry/sentry)** — это инструмент для отслеживания ошибок и производительности приложений в реальном времени.

- Отслеживает баги и exceptions в бекенд, веб и мобильных приложениях.
- Показывает стек вызовов, контекст, окружение, пользователя и другую полезную информацию.
- Помогает разработчикам быстро находить и исправлять баги.
- Поддерживает множество языков и фреймворков

## Отличия от предыдущего поста про [Sentry](https://habr.com/ru/companies/magnit/articles/831264/)
- Используются Kafka, ClickHouse вне Kubernetes
- Для Nodestore используется S3
- Добавлен пример сборки кастомных image sentry, snuba, replay с сертификатом от yandex
- Подключение Kafka, Redis, ClickHouse, Postgres через SSL.
- Динамическое формирование values для helm чарта sentry

## Быстрый старт

Меняем dns зону и dns запись в файле ip-dns.tf

Запускаем инфраструктуру:

```shell
export YC_FOLDER_ID='ваша подсеть'
terraform init
terraform apply
```

Формируем kubeconfig для кластера k8s с указанным ID (xxx) в Yandex Cloud, используя внешний IP (--external)
```shell
yc managed-kubernetes cluster get-credentials --id xxx --external --force
```

Проверяем сгенерированный конфиг values_sentry.yaml из шаблона

## Деплоим Sentry в кластер через Helm
```shell
kubectl create namespace test
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm upgrade --install sentry -n test sentry/sentry --version 26.15.1 -f values_sentry.yaml
```

## Простой пример отправки exception

- Заходим в директорию `example-python`
- Запускаем python код
```shell
cd example-python
python3 -m venv venv
source venv/bin/activate
pip install --upgrade sentry-sdk
python3 main.py
```

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
В terraform коде в комментариях указано как настраивать SSL.

## Структура Terraform проекта

- Список и краткое описание ключевых файлов:
    - `clickhouse.tf` — managed ClickHouse (Yandex Cloud)
    - `kafka.tf` — managed Kafka (Yandex Cloud)
    - `postgres.tf` — managed Postgres (Yandex Cloud)
    - `redis.tf` — для кэширования и очередей managed Redis (Yandex Cloud)
    - `s3_filestore.tf` и `s3_nodestore.tf` — хранилище blob-данных managed S3 (Yandex Cloud)
    - `values_sentry.yaml` и `values_sentry.yaml.tpl` — конфиг для Sentry, параметризуем через Terraform `templatefile`
    - `k8s.tf` — managed Kuberbetes (Yandex Cloud) для деплоя Sentry
    - `example-python` — демонстрация, как отправлять ошибки в Sentry из Python
    - `locals.tf` – определяет локальные переменные, используемые в других файлах Terraform.
    - `net.tf` – описывает сетевые ресурсы, такие как VPC, подсети и маршруты.
    - `ip-dns.tf` – настраивает IP-адреса и записи DNS для ресурсов.
    - `versions.tf` – задаёт версии Terraform и провайдеров, необходимых для работы проекта.

## Хранение основных данных (Nodestore) в S3
Отмечу отдельно что основные данные (Nodestore) хранятся в S3
Файл `s3_nodestore.tf` — хранилище blob-данных managed S3 (Yandex Cloud)
В файле values_sentry.yaml указание где хранить Nodestore указывается так
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

## Динамическое формирование файла values.yaml
## Формирование values.yaml для Sentry

- Файл values.yaml (`values_sentry.yaml`) формируется используя шаблон `values_sentry.yaml.tpl` и `templatefile.tf`
- Как шаблон превращается в финальный конфиг (через `templatefile()` в Terraform)


## Собираем кастомные image с сертификатом и sentry-s3-nodestore модулем
Код сборок находится либо в этих репозиториях:
- https://github.com/patsevanton/ghcr-relay-custom-images
- https://github.com/patsevanton/ghcr-snuba-custom-images
- https://github.com/patsevanton/ghcr-sentry-custom-images
- либо в https://github.com/patsevanton/sentry-external-kf-ch-pg-rd

В файле enhance-image.sh происходит добавление сертификатов и установка sentry-s3-nodestore.
Сертификаты устанавливаются в python модуль certifi

## Получение паролей
Пароли можно получить посмотрев values_sentry.yaml или используя terraform output

## Планы на будущие посты о Sentry
- Использовать Elasticsearch для nodestore
