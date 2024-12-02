#!/bin/bash

set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    SU=""
else
    SU="sudo"
fi

echo "==> 更新系统并安装依赖..."
$SU apt update && $SU apt upgrade -y
$SU apt install -y python3 python3-pip mailman3 mailman3-web postfix dovecot-core dovecot-imapd nginx certbot python3-certbot-nginx nodejs npm git

echo "==> 配置 Mailman..."
./scripts/configure_mailman.sh

echo "==> 配置 Postfix 和 Dovecot..."
./scripts/configure_mail.sh

echo "==> 配置 WebUI..."
./scripts/setup_webui.sh

echo "==> 配置完成！请重启服务。"

