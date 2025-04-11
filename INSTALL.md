# sentry with external kafka clickhouse postgres redis

```shell
export YC_FOLDER_ID='xxx'
terraform init
terraform apply

kubectl create namespace sentry

helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update
helm upgrade --install sentry -n sentry sentry/sentry --version 26.15.1 -f sentry_config.yaml
```


Run example python
```shell
cd example-python
python3 -m venv venv
source venv/bin/activate
pip install --upgrade sentry-sdk
python3 main.py
```

При указании порта 6380 для redis получаю ошибку. Нужно включить настройку `Поддержка TLS`
```
resource "yandex_mdb_redis_cluster" "<имя_кластера>" {
  tls_enabled         = true
```
