# **Запускаем Sentry в Kubernetes в Яндекс облаке и храним Nodestore в S3**

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
- Подключение Kafka, Redis, ClickHouse, Postgres через SSL (можно отключить).
- Динамическое формирование values для helm чарта sentry

## Быстрый старт в yandex cloud

- Клонируем репозиторий https://github.com/patsevanton/sentry-external-kf-ch-pg-rd
- Меняем dns зону и dns запись в файле ip-dns.tf
- Меняем user_email и system_url в файле templatefile.tf

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
В версии `26.15.1` sentry helm чарта используется `25.2.0` версия sentry

## Пароли
Пароли генерируются динамически, но вы можете указать свои пароль в local.tf
Их можно получить посмотрев values_sentry.yaml или используя terraform output

## Простой пример отправки exception
- Создаем проект в Sentry, выбираем python, копируем DSN
- Заходим в директорию `example-python`
- Меняем dsn в main.py (Сам DSN лучше хранить в секретах (либо брать из env))
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
- Масштабируемость
- Изоляция ресурсов
- Более надежное хранилище

Минусы/предостережения:
- Логирование и трассировка проблем становится чуть сложнее
- Требует аккуратной настройки переменных и IAM-доступов (особенно к S3)

## Подключение Kafka, Redis, ClickHouse, Postgres через SSL
В этом посте в отличие от предыдущего будет подключение Kafka, Redis, Postgres через SSL.
Для подключения ClickHouse по SSL ждем вот этого [PR](https://github.com/sentry-kubernetes/charts/pull/1671).
В terraform коде в комментариях указано как настраивать SSL и как отключать SSL

## Структура Terraform [проекта](https://github.com/patsevanton/sentry-external-kf-ch-pg-rd)
- Список и краткое описание ключевых файлов в [репо](https://github.com/patsevanton/sentry-external-kf-ch-pg-rd):
    - `example-python` — демонстрация, как отправлять ошибки в Sentry из Python
    - `clickhouse.tf` — managed ClickHouse (Yandex Cloud)
    - `ip-dns.tf` – настраивает IP-адреса и записи DNS для ресурсов.
    - `k8s.tf` — managed Kuberbetes (Yandex Cloud) для деплоя Sentry
    - `kafka.tf` — managed Kafka (Yandex Cloud)
    - `locals.tf` – определяет локальные переменные, используемые в других файлах Terraform.
    - `net.tf` – описывает сетевые ресурсы, такие как VPC, подсети и маршруты.
    - `postgres.tf` — managed Postgres (Yandex Cloud)
    - `redis.tf` — для кэширования и очередей managed Redis (Yandex Cloud)
    - `s3_filestore.tf` и `s3_nodestore.tf` — хранилище blob-данных managed S3 (Yandex Cloud)
    - `values_sentry.yaml` и `values_sentry.yaml.tpl` — конфиг для Sentry, параметризуем через Terraform `templatefile`
    - `versions.tf` – задаёт версии Terraform и провайдеров, необходимых для работы проекта.

## Хранение основных данных (Nodestore) в S3
Отмечу отдельно что основные данные (Nodestore) хранятся в S3, так как хранение в PostgreSQL приводит со временем к проблемам и медленной работе Sentry.
Файл `s3_nodestore.tf` — хранилище blob-данных managed S3 (Yandex Cloud).
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

## Динамическое формирование файла values.yaml для helm чарта Sentry
- Файл values.yaml (`values_sentry.yaml`) формируется используя шаблон `values_sentry.yaml.tpl` и `templatefile.tf`
- В финальный конфиг через terraform функцию `templatefile()` превращается в values_sentry.yaml
- В файлах `values_sentry.yaml.tpl` и `templatefile.tf` содержится разные настройки.

## Собираем кастомные image
Вы можете использовать docker image по умолчанию или собрать image.
В этих кастомных image происходит установка сертификатов и установка sentry-s3-nodestore модуля.
Сертификаты устанавливаются в python модуль certifi.
Код сборок находится либо в этих репозиториях:
- https://github.com/patsevanton/ghcr-relay-custom-images
- https://github.com/patsevanton/ghcr-snuba-custom-images
- https://github.com/patsevanton/ghcr-sentry-custom-images
- либо в https://github.com/patsevanton/sentry-external-kf-ch-pg-rd


## Sentry Kubernetes Hook: как это работает
Параметр [asHook](https://github.com/sentry-kubernetes/charts/blob/develop/charts/sentry/values.yaml#L31C1-L31C13) в Sentry Helm chart указывает, что основные контейнерами и миграции должны запуститься перед основными контейнерами.
Это нужно для первого запуска Sentry. После его можно отключить.

## Схема взаимодействия компонентов sentry для понимания как все сложно
![](https://habrastorage.org/webt/yb/-v/ff/yb-vfflyysktkwlddzkwu1knwbg.png)

![](https://habrastorage.org/webt/s_/vj/0w/s_vj0wic87xcmr12wlpokreui8q.png)

![](https://habrastorage.org/webt/zv/vd/2u/zvvd2uv6f_rmtjgjxmp74ekdylo.png)

## Планы на следующие посты про Sentry
- Использовать Elasticsearch для NodeStore
- Расписать про масштабируемость

При публикации опубликовать исходный terraform код