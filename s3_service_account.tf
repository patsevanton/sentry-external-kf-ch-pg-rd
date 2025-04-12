# Создание сервисного аккаунта в Yandex IAM
resource "yandex_iam_service_account" "sa-s3" {
  # Имя сервисного аккаунта
  name = "sa-test-apatsev"
}

# Присваивание роли IAM для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "sa-admin-s3" {
  # Идентификатор папки, в которой будет назначена роль
  folder_id = local.folder_id

  # Роль, которую мы назначаем сервисному аккаунту
  role      = "storage.admin"

  # Сервисный аккаунт, которому будет назначена роль
  member    = "serviceAccount:${yandex_iam_service_account.sa-s3.id}"
}
