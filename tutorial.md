## Лабораторная работа по работе с docker
Работа посвящена изучению технологии работы с контейнерами

## Задачи

- [ ] 1. Ознакомиться со ссылками учебного материала
- [ ] 2. Выполнить инструкцию учебного материала
- [ ] 3. Составить отчет и отправить ссылку преподавателю 

## Задание лабораторной работы
Настройка переменных окружения
```bash
$ export GITHUB_USERNAME=<имя_пользователя>
$ export GIST_TOKEN=<сохраненный_токен>
$ alias edit=<nano|vi|vim|subl>
```
Клонирование репозитория
```sh
$ git clone https://github.com/${GITHUB_USERNAME}/lab06 projects/lab_docker
$ cd projects/lab_docker
```
Изменение удалённого репозитория
```sh
$ git remote remove origin
$ git remote add origin https://github.com/${GITHUB_USERNAME}/lab_docker
```
Установка Docker
```sh
# Debian
$ sudo apt-get update
$ sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Создание файла main.py
```sh
$ cat >> main.py <<EOF
print("Hello, Docker!")
EOF
```
Создание файла requirements.txt
```sh
$ cat >> requirements.txt <<EOF
flask
requests
EOF
```
Создание Dockerfile
```sh
$ cat >> Dockerfile <<EOF
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential 

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "main.py"]
EOF
```
Сборка Docker-образа
```sh
$ docker build -t lab-docker .
$ docker run --rm -it lab-docker
```

## И здесь начался треш!
```sh
ERROR: permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

## Решение:


```sh
usermod: группа «docker» не существует
```
Значит группа docker не была создана при установке Docker. Исправлялка:
```sh
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
$ sudo reboot
``` 
Последняя команда - перезагрузка. Либо:
```sh
$ sudo apt update
$ sudo apt install -y docker.io docker-compose-v2
```
### Docker compose

```sh
$ cat >> docker-compose.yml <<EOF
version: '3.8'

services:
  app:
    build: . 
    container_name: lab_docker
    depends_on:
      db:
        condition: service_healthy
    environment:
      - DB_HOST=$DB_HOST
      - DB_USER=$DB_USER
      - DB_PASSWORD=$DB_PASSWORD
      - DB_NAME=$DB_NAME

  # Сервис базы данных MySQL
  db:
    image: mysql:8.0
    container_name: mysql_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $DB_ROOT_PASSWORD
      MYSQL_DATABASE: $DB_NAME
      MYSQL_USER: $DB_USER
      MYSQL_PASSWORD: $DB_PASSWORD
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  db_data:
EOF
```

<details>
<summary>docker build -t lab-docker .</summary>
<pre>
[+] Building 31.1s (11/11) FINISHED                                                                                                    docker:default
 => [internal] load build definition from Dockerfile                                                                                             0.0s
 => => transferring dockerfile: 251B                                                                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim                                                                               4.2s
 => [internal] load .dockerignore                                                                                                                0.0s
 => => transferring context: 2B                                                                                                                  0.0s
 => [1/6] FROM docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf1731b1b                         2.8s
 => => resolve docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf1731b1b                         0.0s
 => => sha256:c23f4b50347300e01a1a1da6dd0266adcf8e44671002ad28c2386cb6557943d6 251B / 251B                                                       0.3s
 => => sha256:ebfe7d4fa0c501a81a5ba6d1e1e2958e4b005d3ce3827b0adb869d47b8c51229 13.83MB / 13.83MB                                                 1.2s
 => => sha256:479b8ad8bcc3edbeba82d4959dfbdc65226d5b55df3f36914c68455762bf924c 1.27MB / 1.27MB                                                   1.0s
 => => sha256:a16e551192670581ec8359c70ab9eebf8f2af5468ffc79b3d4f9ce21b0366f47 30.14MB / 30.14MB                                                 2.1s
 => => extracting sha256:a16e551192670581ec8359c70ab9eebf8f2af5468ffc79b3d4f9ce21b0366f47                                                        0.4s
 => => extracting sha256:479b8ad8bcc3edbeba82d4959dfbdc65226d5b55df3f36914c68455762bf924c                                                        0.0s
 => => extracting sha256:ebfe7d4fa0c501a81a5ba6d1e1e2958e4b005d3ce3827b0adb869d47b8c51229                                                        0.2s
 => => extracting sha256:c23f4b50347300e01a1a1da6dd0266adcf8e44671002ad28c2386cb6557943d6                                                        0.0s
 => [internal] load build context                                                                                                                0.0s
 => => transferring context: 1.27MB                                                                                                              0.0s
 => [2/6] WORKDIR /app                                                                                                                           0.2s
 => [3/6] RUN apt-get update && apt-get install -y     build-essential                                                                          10.7s
 => [4/6] COPY requirements.txt .                                                                                                                0.0s 
 => [5/6] RUN pip install --no-cache-dir -r requirements.txt                                                                                     5.2s 
 => [6/6] COPY . .                                                                                                                               0.0s 
 => exporting to image                                                                                                                           7.8s 
 => => exporting layers                                                                                                                          6.3s 
 => => exporting manifest sha256:c45eaf74044efa8ffdbceee4d7f18281b916c397e26a6ee848154d8a13df5cd9                                                0.0s 
 => => exporting config sha256:9b5d900e81cf955ee6bd8869665524af48c859e71e912bfc327cca954441befe                                                  0.0s 
 => => exporting attestation manifest </pre>
</details>

## ПРикол №2:
<details>
<summary> docker build -t lab-docker .</summary>
  <pre>
WARN[0000] /home/vboxuser/projects/lab_docker/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] up 14/14
 ✔ Image mysql:8.0 Pulled                                                                                                                        16.0s
[+] Building 1.1s (13/13) FINISHED                                                                                                                    
 => [internal] load local bake definitions                                                                                                       0.0s
 => => reading from stdin 514B                                                                                                                   0.0s
 => [internal] load build definition from Dockerfile                                                                                             0.0s
 => => transferring dockerfile: 251B                                                                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim                                                                               0.6s
 => [internal] load .dockerignore                                                                                                                0.0s
 => => transferring context: 2B                                                                                                                  0.0s
 => [1/6] FROM docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf1731b1b                         0.0s
 => => resolve docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf1731b1b                         0.0s
 => [internal] load build context                                                                                                                0.0s
 => => transferring context: 3.77kB                                                                                                              0.0s
 => CACHED [2/6] WORKDIR /app                                                                                                                    0.0s
 => CACHED [3/6] RUN apt-get update && apt-get install -y     build-essential                                                                    0.0s
 => CACHED [4/6] COPY requirements.txt .                                                                                                         0.0s
 => CACHED [5/6] RUN pip install --no-cache-dir -r requirements.txt                                                                              0.0s
 => [6/6] COPY . .                                                                                                                               0.3s
 => exporting to image                                                                                                                           0.1s
 => => exporting layers                                                                                                                          0.1s
 => => exporting manifest sha256:ebff914d1f77eda41d8386c2356838ea3d849bd19f32b08aff4b631013b24e98                                                0.0s
 => => exporting config sha256:adf50c5f72314b8e6784b6a249512f6925b945022cd3fd90159512dcecc35ca6                                                  0.0s
 => => exporting attestation manifest sha256:1106577338232b2d3cb460d017d28a4f3460136d0509901a1645a373c8fa43e7                                    0.0s
 => => exporting manifest list sha256:d4485921a77c279ebc8470a77dcabd92f1d69ac107ab6364f7acbc89a252300b                                           0.0s
 => => naming to docker.io/library/lab_docker-app:latest                                                                                         0.0s
[+] up 19/19king to docker.io/library/lab_docker-app:latest                                                                                      0.0s
 ✔ Image
mysql:8.0            Pulled                                                                                                             16.0s
 ✔ Image lab_docker-app       Built                                                                                                              1.2s
 ✔ Network lab_docker_default Created                                                                                                            0.1s
 ✔ Volume lab_docker_db_data  Created                                                                                                            0.0s
 ✔ Container mysql_db         Created                                                                                                            0.0s
 ✔ Container lab_docker       Created                                                                                                            0.0s
Attaching to lab_docker, mysql_db
Container mysql_db Waiting 
mysql_db  | 2026-05-02 15:01:34+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:01:34+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
mysql_db  | 2026-05-02 15:01:34+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:01:34+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
mysql_db  |     You need to specify one of the following as an environment variable:
mysql_db  |     - MYSQL_ROOT_PASSWORD
mysql_db  |     - MYSQL_ALLOW_EMPTY_PASSWORD
mysql_db  |     - MYSQL_RANDOM_ROOT_PASSWORD
mysql_db exited with code 1 (restarting)
mysql_db  | 2026-05-02 15:01:35+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:01:35+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
mysql_db  | 2026-05-02 15:01:35+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:01:35+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
mysql_db  |     You need to specify one of the following as an environment variable:
mysql_db  |     - MYSQL_ROOT_PASSWORD
mysql_db  |     - MYSQL_ALLOW_EMPTY_PASSWORD
mysql_db  |     - MYSQL_RANDOM_ROOT_PASSWORD
mysql_db exited with code 1 (restarting)
mysql_db  | 2026-05-02 15:01:35+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:01:35+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
mysql_db  | 2026-05-02 15:01:35+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:01:35+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
mysql_db  |     You need to specify one of the following as an environment variable:
mysql_db  |     - MYSQL_ROOT_PASSWORD
mysql_db  |     - MYSQL_ALLOW_EMPTY_PASSWORD
mysql_db  |     - MYSQL_RANDOM_ROOT_PASSWORD
Container mysql_db Error dependency db failed to start
dependency failed to start: container mysql_db is unhealthy</pre>
</details>

## О проблеме:
Это типичная ошибка MySQL в compose: чаще всего переменные БД оказались пустыми или остался старый volume с неудачной инициализацией.
```sh
$ cd ~/projects/lab_docker
$ ls
```
Должно быть:
```sh
Dockerfile
main.py
requirements.txt
docker-compose.yml
```
Решение:
```sh
$ sudo docker compose down -v
$ sudo docker rm -f mysql_db lab_docker 2>/dev/null
$ cat > .env <<EOF
DB_HOST=db
DB_USER=labuser
DB_PASSWORD=labpass
DB_NAME=labdb
DB_ROOT_PASSWORD=rootpass
EOF

$ cat > docker-compose.yml <<'EOF'
services:
  app:
    build: .
    container_name: lab_docker
    depends_on:
      db:
        condition: service_healthy
    environment:
      DB_HOST: ${DB_HOST}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME}

  db:
    image: mysql:8.0
    container_name: mysql_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -uroot -p$${MYSQL_ROOT_PASSWORD} || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

volumes:
  db_data:
EOF
$ sudo docker compose up --build
```

<details>
<summary>sudo docker compose up --build</summary>
<pre>
[+] Building 0.9s (13/13) FINISHED                                                                                                                    
 => [internal] load local bake definitions                                                                                                       0.0s
 => => reading from stdin 514B                                                                                                                   0.0s
 => [internal] load build definition from Dockerfile                                                                                             0.0s
 => => transferring dockerfile: 251B                                                                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.9-slim                                                                               0.6s
 => [internal] load .dockerignore                                                                                                                0.0s
 => => transferring context: 2B                                                                                                                  0.0s
 => [internal] load build context                                                                                                                0.0s
 => => transferring context: 1.27MB                                                                                                              0.0s
 => [1/6] FROM docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf1731b1b                         0.0s
 => => resolve docker.io/library/python:3.9-slim@sha256:2d97f6910b16bd338d3060f261f53f144965f755599aab1acda1e13cf1731b1b                         0.0s
 => CACHED [2/6] WORKDIR /app                                                                                                                    0.0s
 => CACHED [3/6] RUN apt-get update && apt-get install -y     build-essential                                                                    0.0s
 => CACHED [4/6] COPY requirements.txt .                                                                                                         0.0s
 => CACHED [5/6] RUN pip install --no-cache-dir -r requirements.txt                                                                              0.0s
 => [6/6] COPY . .                                                                                                                               0.0s
 => exporting to image                                                                                                                           0.1s
 => => exporting layers                                                                                                                          0.0s
 => => exporting manifest sha256:c77a99d8998e4bb3fd68354342defb96fe9428bbd47cfb1f932f45ed9aa8987f                                                0.0s
 => => exporting config sha256:2428885158a30dc67e1dec5b856ead610c4c8b3c1d710ac393f276977111b43f                                                  0.0s
 => => exporting attestation manifest sha256:2de3bd4470718e195fb7081f51feab9548e4f79e48ada67a9820b0b7b3b0f9f7                                    0.0s
 => => exporting manifest list sha256:6ad2ad5b10cd2f62efbc6a4bf7bab10ea12906f1bba3ed93a45771bea83e7ff7                                           0.0s
 => => naming to docker.io/library/lab_docker-app:latest                                                                                         0.0s
 => => unpacking to docker.io/library/lab_docker-app:latest                                                                                      0.0s
 => resolving provenance for metadata file                                                                                                       0.0s
[+] up 5/5
 ✔ Image lab_docker-app       Built                                                                                                               0.9s
 ✔ Network lab_docker_default
Created                                                                                                             0.1s
 ✔ Volume lab_docker_db_data  Created                                                                                                             0.0s
 ✔ Container mysql_db         Created                                                                                                             0.0s
 ✔ Container lab_docker       Created                                                                                                             0.0s
Attaching to lab_docker, mysql_db
mysql_db  | 2026-05-02 15:04:10+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
Container mysql_db Waiting 
mysql_db  | 2026-05-02 15:04:10+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
mysql_db  | 2026-05-02 15:04:10+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.46-1.el9 started.
mysql_db  | 2026-05-02 15:04:10+00:00 [Note] [Entrypoint]: Initializing database files
mysql_db  | 2026-05-02T15:04:10.876925Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
mysql_db  | 2026-05-02T15:04:10.876974Z 0 [System] [MY-013169] [Server] /usr/sbin/mysqld (mysqld 8.0.46) initializing of server in progress as process 80
mysql_db  | 2026-05-02T15:04:10.882157Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
mysql_db  | 2026-05-02T15:04:11.040855Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
mysql_db  | 2026-05-02T15:04:11.415001Z 6 [Warning] [MY-010453] [Server] root@localhost is created with an empty password ! Please consider switching off the --initialize-insecure option.
mysql_db  | 2026-05-02 15:04:13+00:00 [Note] [Entrypoint]: Database files initialized
mysql_db  | 2026-05-02 15:04:13+00:00 [Note] [Entrypoint]: Starting temporary server
mysql_db  | 2026-05-02T15:04:13.285602Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
mysql_db  | 2026-05-02T15:04:13.286164Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.46) starting as process 124
mysql_db  | 2026-05-02T15:04:13.293905Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
mysql_db  | 2026-05-02T15:04:13.361969Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
mysql_db  | 2026-05-02T15:04:13.441848Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
mysql_db  | 2026-05-02T15:04:13.441870Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
mysql_db  | 2026-05-02T15:04:13.443062Z 0 [Warning] [MY-011810] [Server] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
mysql_db  | 2026-05-02T15:04:13.450584Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Socket: /var/run/mysqld/mysqlx.sock
mysql_db  | 2026-05-02T15:04:13.451179Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.46'  socket: '/var/run/mysqld/mysqld.sock'  port: 0  MySQL Community Server - GPL.
mysql_db  | 2026-05-02 15:04:13+00:00 [Note] [Entrypoint]: Temporary server started.
mysql_db  | '/var/lib/mysql/mysql.sock' -> '/var/run/mysqld/mysqld.sock'
mysql_db  | Warning: Unable to load '/usr/share/zoneinfo/iso3166.tab' as time zone. Skipping it.
mysql_db  | Warning: Unable to load '/usr/share/zoneinfo/leap-seconds.list' as time zone. Skipping it.
mysql_db  | Warning: Unable to load '/usr/share/zoneinfo/leapseconds' as time zone. Skipping it.
mysql_db  | Warning: Unable to load '/usr/share/zoneinfo/tzdata.zi' as time zone. Skipping it.
mysql_db  | Warning: Unable to load '/usr/share/zoneinfo/zone.tab' as time zone. Skipping it.
mysql_db  | Warning: Unable to load 
'/usr/share/zoneinfo/zone1970.tab' as time zone. Skipping it.
mysql_db  | 2026-05-02 15:04:14+00:00 [Note] [Entrypoint]: Creating database labdb
mysql_db  | 2026-05-02 15:04:14+00:00 [Note] [Entrypoint]: Creating user labuser
mysql_db  | 2026-05-02 15:04:14+00:00 [Note] [Entrypoint]: Giving user labuser access to schema labdb
mysql_db  | 
mysql_db  | 2026-05-02 15:04:14+00:00 [Note] [Entrypoint]: Stopping temporary server
mysql_db  | 2026-05-02T15:04:14.488262Z 13 [System] [MY-013172] [Server] Received SHUTDOWN from user root. Shutting down mysqld (Version: 8.0.46).
mysql_db  | 2026-05-02T15:04:16.059198Z 0 [System] [MY-010910] [Server] /usr/sbin/mysqld: Shutdown complete (mysqld 8.0.46)  MySQL Community Server - GPL.
mysql_db  | 2026-05-02 15:04:16+00:00 [Note] [Entrypoint]: Temporary server stopped
mysql_db  | 
mysql_db  | 2026-05-02 15:04:16+00:00 [Note] [Entrypoint]: MySQL init process done. Ready for start up.
mysql_db  | 
mysql_db  | 2026-05-02T15:04:16.651689Z 0 [Warning] [MY-011068] [Server] The syntax '--skip-host-cache' is deprecated and will be removed in a future release. Please use SET GLOBAL host_cache_size=0 instead.
mysql_db  | 2026-05-02T15:04:16.652100Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.46) starting as process 1
mysql_db  | 2026-05-02T15:04:16.654727Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
mysql_db  | 2026-05-02T15:04:16.717399Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
mysql_db  | 2026-05-02T15:04:16.778973Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
mysql_db  | 2026-05-02T15:04:16.778993Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
mysql_db  | 2026-05-02T15:04:16.779965Z 0 [Warning] [MY-011810] [Server] Insecure configuration for --pid-file: Location '/var/run/mysqld' in the path is accessible to all OS users. Consider choosing a different directory.
mysql_db  | 2026-05-02T15:04:16.785014Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '::' port: 33060, socket: /var/run/mysqld/mysqlx.sock
mysql_db  | 2026-05-02T15:04:16.785042Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.46'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server - GPL.
Container mysql_db Healthy 
lab_docker  | Hello, Docker!</pre>
</details>
