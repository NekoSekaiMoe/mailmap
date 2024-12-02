#!/bin/bash

set -euo pipefail

echo "==> 安装 WebUI..."
cd frontend
npm install
npm run build

echo "==> 配置 Nginx..."
cat << EOF | $SU tee /etc/nginx/sites-available/mailui
server {
    listen 80;
    server_name mail.example.com;

    root /var/www/mailui;
    index index.html;

    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

$SU ln -s /etc/nginx/sites-available/mailui /etc/nginx/sites-enabled/
$SU systemctl restart nginx

