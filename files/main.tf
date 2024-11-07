terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.default_zone
}

// Create SA
resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "tf-test-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket

resource "yandex_storage_bucket" "murchin-07-11-2024" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "murchin-07-11-2024"
  acl    = "public-read"
  website {
    index_document = "kitten1.jpg"
#    error_document = "error.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
}

resource "yandex_storage_object" "cute-cat-picture" {
  bucket = "murchin-07-11-2024"
  key    = "kitten1.jpg"
  source = "./images/kitten1.jpg"
  tags = {
    test = "value"
  }
}

resource "yandex_vpc_network" "murchin-net" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "public" {
  name           = local.subnet_name1
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = var.default_zone
  network_id     = yandex_vpc_network.murchin-net.id
}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = "example-symetric-key"
  description       = "description for key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}
