#!/bin/bash

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Создание директории для приложения
mkdir -p /var/www/tbank
cd /var/www/tbank

# Создание docker-compose.yml
cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  frontend:
    image: tbank-frontend:latest
    restart: always
    ports:
      - "80:3000"
    environment:
      - NODE_ENV=production
EOL

# Создание скрипта для обновления
cat > update.sh << 'EOL'
#!/bin/bash
cd /var/www/tbank
docker-compose pull
docker-compose up -d
EOL

chmod +x update.sh

# Запуск приложения
docker-compose up -d

# Установка и настройка Nginx (опционально, для проксирования)
apt-get update
apt-get install -y nginx

# Создание конфига Nginx
cat > /etc/nginx/sites-available/tbank << 'EOL'
server {
    listen 80;
    server_name your-domain.com;  # Замените на ваш домен

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOL

# Активация конфига Nginx
ln -s /etc/nginx/sites-available/tbank /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Установка Certbot для SSL
apt-get install -y certbot python3-certbot-nginx

echo "Настройка завершена! Теперь выполните:"
echo "1. Замените 'your-domain.com' в конфиге Nginx на ваш домен"
echo "2. Запустите: certbot --nginx -d your-domain.com"
echo "3. Загрузите ваш Docker образ на сервер"
echo "4. Запустите update.sh для обновления приложения" 