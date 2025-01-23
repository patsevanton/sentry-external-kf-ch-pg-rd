resource "yandex_iam_service_account" "sa-k8s-editor" {
  folder_id = local.folder_id
  name      = "sa-k8s-editor"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-k8s-editor-permissions" {
  folder_id = local.folder_id # var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
  role      = "editor"

  member = "serviceAccount:${yandex_iam_service_account.sa-k8s-editor.id}"
}

resource "time_sleep" "wait_sa" {
  create_duration = "20s"
  depends_on      = [
    yandex_iam_service_account.sa-k8s-editor,
    yandex_resourcemanager_folder_iam_member.sa-k8s-editor-permissions
  ]
}

resource "yandex_kubernetes_cluster" "sentry" {
  name       = "sentry"
  folder_id  = local.folder_id
  network_id = yandex_vpc_network.sentry.id

  master {
    version = "1.30"
    zonal {
      zone      = yandex_vpc_subnet.sentry-a.zone
      subnet_id = yandex_vpc_subnet.sentry-a.id
    }

    public_ip = true
  }
  service_account_id      = yandex_iam_service_account.sa-k8s-editor.id
  node_service_account_id = yandex_iam_service_account.sa-k8s-editor.id
  release_channel         = "STABLE"
  // to keep permissions of service account on destroy
  // until cluster will be destroyed
  depends_on = [time_sleep.wait_sa]
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {
  description = "Node group for the Managed Service for Kubernetes cluster"
  name        = "k8s-node-group"
  cluster_id  = yandex_kubernetes_cluster.sentry.id
  version     = local.k8s_version

  scale_policy {
    fixed_scale {
      size = local.number_of_k8s_hosts
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.sentry-a.zone
    }

    location {
      zone = yandex_vpc_subnet.sentry-b.zone
    }

    location {
      zone = yandex_vpc_subnet.sentry-d.zone
    }
  }


  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat = true
      subnet_ids = [
        yandex_vpc_subnet.sentry-a.id,
        yandex_vpc_subnet.sentry-b.id,
        yandex_vpc_subnet.sentry-d.id
      ]
    }

    resources {
      memory = local.memory_of_k8s_hosts
      cores  = local.cores_of_k8s_hosts
    }

    boot_disk {
      type = "network-ssd"
      size = local.boot_disk
    }
  }
}
