

## Часть I. Docker

1. Добавьте в код Dockerfile, который позволит запустить web-приложение с исходным кодом в каталоге app/ через docker.
```sh
cat > Dockerfile <<'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python", "app.py"]
EOF
```
2. Выполните запуск контейнера с этим приложением.
```sh
sudo docker build -t lab06-dockerhom .
```
```sh
sudo docker run -d \
  --name lab06_dockerhom_app \
  -p 8080:5000 \
  -e DB_HOST=localhost \
  -e DB_USER=labuser \
  -e DB_PASS=labpass \
  -e DB_NAME=labdb \
  lab06-dockerhom
```
3. Скопируйте из консоли в каталог /home/ контейнера файл README.md.
```sh
sudo docker cp README.md lab06_dockerhom_app:/home/README.md
```
4. Подключитесь к терминалу контейнера с приложением в интерактивном режиме. Проверьте, что скопированный файл находится в нужном каталоге.
```sh
sudo docker exec -it lab06_dockerhom_app sh
ls -l /home
```
5. Выйдите из интерактивного режима.
```sh
exit
```
6. Остановите контейнер с приложением.
```sh
sudo docker stop lab06_dockerhom_app
sudo docker rm lab06_dockerhom_app
```

## Часть II. Docker compose
1. Создайте файл docker-compose.yml таким образом, чтобы совместно с описанным в части 1 контейнером работала бы база данных mysql. Файл инициализации БД в каталоге db/init.sql. Также пропишите порт подключения к приложению. Например 5000.
Создание env:
```sh
cat > .env <<'EOF'
DB_HOST=db
DB_USER=labuser
DB_PASS=labpass
DB_NAME=labdb
DB_ROOT_PASSWORD=rootpass
EOF
```
ОШИБКА С РУССКИМИ ДАННЫМИ:
```sh
cat > db/init.sql <<'EOF'
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

ALTER DATABASE labdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

DROP TABLE IF EXISTS items;

CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO items (name) VALUES
('Пример 1'),
('Пример 2');
EOF
```
Создание docker-compose.yml:
```sh
cat > docker-compose.yml <<'EOF'
services:
  app:
    build: .
    container_name: lab06_dockerhom_app
    ports:
      - "8080:5000"
    environment:
      DB_HOST: ${DB_HOST}
      DB_USER: ${DB_USER}
      DB_PASS: ${DB_PASS}
      DB_NAME: ${DB_NAME}
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mysql:8.0
    container_name: lab06_dockerhom_mysql
    restart: always
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASS}
    volumes:
      - db_data:/var/lib/mysql
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -uroot -p$${MYSQL_ROOT_PASSWORD} || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

volumes:
  db_data:
EOF
```


2. Запустите связку web-приложение - БД.
```sh
sudo docker compose down -v
sudo docker compose up --build
```


3. Проверьте подключение к приложению через браузер. Сделайте снимок экрана.
```sh
http://localhost:8080
```


4. Проверьте работу приложения через браузер.

<img width="1280" height="800" alt="VirtualBox_Ubunta_02_05_2026_20_57_53" src="https://github.com/user-attachments/assets/961ee1da-2fbf-48c8-91ac-8c51359f76e6" />
