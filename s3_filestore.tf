# Создание статического ключа доступа для учетной записи сервиса в Yandex IAM
resource "yandex_iam_service_account_static_access_key" "filestore_bucket_key" {
  # ID учетной записи сервиса, для которой создается ключ доступа
  service_account_id = yandex_iam_service_account.sa-s3.id

  # Описание для ключа доступа
  description        = "static access key for object storage"
}

# Создание бакета (хранилища) в Yandex Object Storage
resource "yandex_storage_bucket" "filestore" {
  # Название бакета
  bucket     = local.filestore_bucket

  # Доступ и секретный ключ, полученные от статического ключа доступа
  access_key = yandex_iam_service_account_static_access_key.filestore_bucket_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.filestore_bucket_key.secret_key

  # ID папки, в которой будет размещен бакет
  folder_id = local.folder_id

  # Указываем зависимость от ресурса IAM-члена, который должен быть создан до бакета
  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa-admin-s3,
  ]
}

# Вывод ключа доступа для бакета (с чувствительным значением)
output "access_key_for_filestore_bucket" {
  # Описание вывода
  description = "access_key filestore_bucket"

  # Значение для вывода (ключ доступа к бакету)
  value       = yandex_storage_bucket.filestore.access_key

  # Указание, что выводимое значение чувствительно
  sensitive   = true
}

# Вывод секретного ключа для бакета (с чувствительным значением)
output "secret_key_for_filestore_bucket" {
  # Описание вывода
  description = "secret_key filestore_bucket"

  # Значение для вывода (секретный ключ для бакета)
  value       = yandex_storage_bucket.filestore.secret_key

  # Указание, что выводимое значение чувствительно
  sensitive   = true
}
