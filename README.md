# Домашняя работа "Реализация GFS2 хранилища"

Цель работы: с помощью terraform и ansible развернуть в Яндекс Облаке хранилище GFS2.

Данный репозиторий содержит:

- Манифесты terraform для создания инфраструктуры проекта:
   - ВМ с ISCSI
   - 3 ноды с GFS2 поверх cluster LVM на томе ISCSI 
   - ВМ выполняющую роли ansible и джамп-хоста для доступа в локальную сеть проекта
- Роли ansible для приведения виртуальных машин в проекте в требуемое состояние.

При разворачивании стенда создаются ВМ с параметрами:
- 2 CPU;
- 2 GB RAM;
- 10 GB диск;
- операционная система CentOS 8 Stream;

Для разворачивания стенда необходимо:

1. В файле *variables.tf* заполнить значения переменных, необходимых для доступа к облаку Яндекс:
     - cloud-id (посмотреть в веб-консоли yandex cloud)
     - folder-id (посмотреть в веб-консоли yandex cloud)
     - iam-token (получить с помощью команды *$ yc iam create-token* )

2. Инициализировать рабочую среду Terraform:

```
$ terraform init
```
В результате будет установлен провайдер для подключения к облаку Яндекс.

3. Запустить разворачивание стенда:
```
$ terraform apply
```

В выходных данных будут показаны все внешние и внутренние ip адреса. Для проверки работы стенда необходимо зайти по ssh на джамп-хост, с которого, в свою очередь так же по ssh, можно попасть на ВМ с ISCSI и GFS2 по их внутренним ip-адресам или hostname.

Для этого из рабочей папки проекта надо выполнить:

```
[homework_gf2]$ ssh cloud-user@{external_ip_address_ansible} -i id_rsa
```
**external_ip_address_ansible** можно посмотреть в выводе terraform или консоли yandex.cloud.

Доступ по ssh к нодам хранилища GFS2:

```
[cloud-user@ansible]$ ssh gfs-server0

[cloud-user@ansible]$ ssh gfs-server1

[cloud-user@ansible]$ ssh gfs-server2

[cloud-user@ansible]$ ssh iscsi
```

Далее, с любой ноды кластера можно запустить 

```
[gfs-server0]$ pcs status --full

```
и увидеть полный статус кластера с запущенными ресурсами:

```
Cluster name: gfs2_cluster
Status of pacemakerd: 'Pacemaker is running' (last updated 2022-12-30 09:24:41 +03:00)
Cluster Summary:
  * Stack: corosync
  * Current DC: 192.168.100.30 (3) (version 2.1.5-4.el8-a3f44794f94) - partition with quorum
  * Last updated: Fri Dec 30 09:24:41 2022
  * Last change:  Fri Dec 30 09:03:49 2022 by root via cibadmin on 192.168.100.15
  * 3 nodes configured
  * 12 resource instances configured

Node List:
  * Node 192.168.100.15 (1): online, feature set 3.16.2
  * Node 192.168.100.30 (3): online, feature set 3.16.2
  * Node 192.168.100.33 (2): online, feature set 3.16.2

Full List of Resources:
  * Clone Set: locking-clone [locking]:
    * Resource Group: locking:0:
      * dlm     (ocf::pacemaker:controld):       Started 192.168.100.33
      * lvmlockd        (ocf::heartbeat:lvmlockd):       Started 192.168.100.33
    * Resource Group: locking:1:
      * dlm     (ocf::pacemaker:controld):       Started 192.168.100.30
      * lvmlockd        (ocf::heartbeat:lvmlockd):       Started 192.168.100.30
    * Resource Group: locking:2:
      * dlm     (ocf::pacemaker:controld):       Started 192.168.100.15
      * lvmlockd        (ocf::heartbeat:lvmlockd):       Started 192.168.100.15
  * Clone Set: shared_vg-clone [shared_vg]:
    * Resource Group: shared_vg:0:
      * shared_lv       (ocf::heartbeat:LVM-activate):   Started 192.168.100.33
      * shared_fs       (ocf::heartbeat:Filesystem):     Started 192.168.100.33
    * Resource Group: shared_vg:1:
      * shared_lv       (ocf::heartbeat:LVM-activate):   Started 192.168.100.30
      * shared_fs       (ocf::heartbeat:Filesystem):     Started 192.168.100.30
    * Resource Group: shared_vg:2:
      * shared_lv       (ocf::heartbeat:LVM-activate):   Started 192.168.100.15
      * shared_fs       (ocf::heartbeat:Filesystem):     Started 192.168.100.15

Migration Summary:

Tickets:

PCSD Status:
  192.168.100.15: Online
  192.168.100.30: Online
  192.168.100.33: Online

Daemon Status:
  corosync: active/enabled
  pacemaker: active/enabled
  pcsd: active/enabled
```

С чем столкнулся во время выполнения работы:
- долго не мог понять, почему не стартуют ресурсы dlm, пока не откопал параметр *allow_stonith_disabled=1*, который обязательно надо указывать при отключенном STONITH (*pcs property set stonith-enabled=false*)
