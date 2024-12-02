#!/bin/bash

set -eux

if [ "$(id -u)" -eq 0 ]; then
    export SU=
else
    export SU=sudo
fi

# 更新系统
"$SU" apt update && "$SU" apt upgrade -y

# 安装依赖
"$SU" apt install -y postfix dovecot-core dovecot-imapd mailman python3 python3-pip certbot python3-certbot-nginx python3-postorius python3-hyperkitty

# 安装 Django
$SU apt install python3-django -y

# 创建 Django 项目
mkdir -p /var/lib/mailman-web
cd /var/lib/mailman-web
django-admin startproject mailman_web .

# 检查 manage.py 是否生成
ls manage.py

# 配置 Postfix
"$SU" dpkg-reconfigure postfix
"$SU" cp /etc/postfix/main.cf /etc/postfix/main.cf.bak || true

cat << EOF | "$SU" tee /etc/postfix/main.cf
myhostname = mail.example.com
mydomain = example.com
myorigin = \$mydomain
inet_interfaces = all
inet_protocols = ipv4
home_mailbox = Maildir/
mydestination = \$myhostname, example.com, localhost.localdomain, localhost
smtpd_tls_cert_file=/etc/letsencrypt/live/mail.example.com/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.example.com/privkey.pem
smtpd_use_tls=yes
EOF

# 配置 Dovecot
"$SU" cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak || true

cat << EOF | "$SU" tee /etc/dovecot/dovecot.conf
protocols = imap
mail_location = maildir:~/Maildir
ssl_cert = </etc/letsencrypt/live/mail.example.com/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.example.com/privkey.pem
EOF

# 停止服务并申请证书
"$SU" systemctl stop postfix dovecot
"$SU" certbot certonly --standalone -d mail.example.com
"$SU" systemctl start postfix dovecot

# 设置证书自动更新
(crontab -l 2>/dev/null; echo "0 3 * * * $SU certbot renew --quiet && $SU systemctl reload postfix dovecot") | crontab -

# 配置 Mailman
cat << EOF | "$SU" tee /etc/mailman.cfg
[mailman]
site_owner: admin@example.com
EOF

"$SU" systemctl enable mailman
"$SU" systemctl start mailman

"$SU" ln -s /var/lib/mailman/archives/private /opt/mail_archive

# 配置 Mailman Web
cat << EOF | "$SU" tee /etc/mailman-web/settings.py
import os
SECRET_KEY = os.getenv("SECRET_KEY", "default_secret_key")
DEBUG = False
ALLOWED_HOSTS = ['example.com']
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/var/lib/mailman-web/data/mailman-web.sqlite',
    }
}
EOF

SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
echo "export SECRET_KEY=$SECRET_KEY" | "$SU" tee -a /etc/environment



"$SU" python3 manage.py migrate
"$SU" python3 manage.py shell <<EOF
from django.contrib.auth.models import User
User.objects.create_superuser('admin', 'admin@example.com', 'your_password')
EOF
$SU python3 manage.py createsuperuser
"$SU" python3 manage.py runserver 0.0.0.0:8000
