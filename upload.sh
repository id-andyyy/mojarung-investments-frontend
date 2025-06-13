#!/bin/bash

# Конфигурация
SERVER_USER="your-username"
SERVER_IP="your-server-ip"
SERVER_PATH="/var/www/tbank"

# Сборка образа
echo "Building Docker image..."
docker build -t tbank-frontend:latest .

# Сохранение образа в файл
echo "Saving Docker image..."
docker save tbank-frontend:latest > tbank-frontend.tar

# Загрузка образа на сервер
echo "Uploading to server..."
scp tbank-frontend.tar $SERVER_USER@$SERVER_IP:$SERVER_PATH/

# Загрузка образа на сервере
echo "Loading image on server..."
ssh $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && \
    docker load < tbank-frontend.tar && \
    rm tbank-frontend.tar && \
    ./update.sh"

# Очистка локальных файлов
echo "Cleaning up..."
rm tbank-frontend.tar

echo "Deployment completed!" 