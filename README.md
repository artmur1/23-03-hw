# Домашнее задание к занятию «Безопасность в облачных провайдерах» - `Мурчин Артем`

Используя конфигурации, выполненные в рамках предыдущих домашних заданий, нужно добавить возможность шифрования бакета.

---
## Задание 1. Yandex Cloud   

1. С помощью ключа в KMS необходимо зашифровать содержимое бакета:

 - создать ключ в KMS;
 - с помощью ключа зашифровать содержимое бакета, созданного ранее.
2. (Выполняется не в Terraform)* Создать статический сайт в Object Storage c собственным публичным адресом и сделать доступным по HTTPS:

 - создать сертификат;
 - создать статическую страницу в Object Storage и применить сертификат HTTPS;
 - в качестве результата предоставить скриншот на страницу с сертификатом в заголовке (замочек).

Полезные документы:

- [Настройка HTTPS статичного сайта](https://cloud.yandex.ru/docs/storage/operations/hosting/certificate).
- [Object Storage bucket](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket).
- [KMS key](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_symmetric_key).

## Решение 1. Yandex Cloud   

main.tf - https://github.com/artmur1/23-03-hw/blob/main/files/main.tf

locals.tf - https://github.com/artmur1/23-03-hw/blob/main/files/locals.tf

variables.tf - https://github.com/artmur1/23-03-hw/blob/main/files/variables.tf

В терраформ создал ключ в KMS:

    resource "yandex_kms_symmetric_key" "key-a" {
      name              = "example-symetric-key"
      description       = "description for key"
      default_algorithm = "AES_128"
      rotation_period   = "8760h" // equal to 1 year
    }

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-01.png)

С помощью ключа зашифровал содержимое бакета:

      server_side_encryption_configuration {
        rule {
          apply_server_side_encryption_by_default {
            kms_master_key_id = yandex_kms_symmetric_key.key-a.id
            sse_algorithm     = "aws:kms"
          }
        }
      }

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-02.png)

Видно, что файл зашифрован:

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-03.png)

А также отображение содержимого на сайте запрещено:

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-04.png)

Решил, что так дело не пойдет, и надо создавать сертификат. Сертификат создал. Отключил на сайте шифрование. Загрузил файл по инструкции по пути: 
http://murchin-07-11-2024.website.yandexcloud.net/.well-known/acme-challenge/Имя_файла. Сертификат прошел валидацию:

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-05.png)

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-06.png)

Но когда захожу в настройки безопасности HTTPS, выходит сообщение "У вас пока нет ни одного подходящего сертификата: имя домена из списка доменов в сертификате должно совпадать с именем бакета". Странно..

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-07.png)

Перехожу в Certificare manager - тут уже 2 сертификата со статусом Issued. На всякий случай создал 3-й сертификат и загрузил на сайт в зашифрованном виде, но он так и не прошел пока проверку...:

![](https://github.com/artmur1/23-03-hw/blob/main/img/23-3-01-08.png)

--- 
## Задание 2*. AWS (задание со звёздочкой)

Это необязательное задание. Его выполнение не влияет на получение зачёта по домашней работе.

**Что нужно сделать**

1. С помощью роли IAM записать файлы ЕС2 в S3-бакет:
 - создать роль в IAM для возможности записи в S3 бакет;
 - применить роль к ЕС2-инстансу;
 - с помощью bootstrap-скрипта записать в бакет файл веб-страницы.
2. Организация шифрования содержимого S3-бакета:

 - используя конфигурации, выполненные в домашнем задании из предыдущего занятия, добавить к созданному ранее бакету S3 возможность шифрования Server-Side, используя общий ключ;
 - включить шифрование SSE-S3 бакету S3 для шифрования всех вновь добавляемых объектов в этот бакет.

3. *Создание сертификата SSL и применение его к ALB:

 - создать сертификат с подтверждением по email;
 - сделать запись в Route53 на собственный поддомен, указав адрес LB;
 - применить к HTTPS-запросам на LB созданный ранее сертификат.

Resource Terraform:

- [IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role).
- [AWS KMS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key).
- [S3 encrypt with KMS key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object#encrypting-with-kms-key).

Пример bootstrap-скрипта:

```
#!/bin/bash
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><h1>My cool web-server</h1></html>" > index.html
aws s3 mb s3://mysuperbacketname2021
aws s3 cp index.html s3://mysuperbacketname2021
```

### Правила приёма работы

Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
