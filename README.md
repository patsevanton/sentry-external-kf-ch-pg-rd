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


ModuleNotFoundError: No module named 'sentry_s3_nodestore'
