#!/bin/bash

set -eux

 if [ "$(id -u)" -eq 0 ]; then
     export SU=
 else
     export SU=sudo
 fi

"$SU" apt update && "$SU" apt upgrade -y
"$SU" apt install postfix dovecot-core dovecot-imapd mailman python3 python3-pip certbot python3-certbot-nginx

"$SU" dpkg-reconfigure postfix

test -f /etc/postfix/main.cf || "$SU" rm /etc/postfix/main.cf

cat << EOF | "$SU" tee -a /etc/postfix/main.cf
myhostname = mail.example.com
mydomain = example.com
myorigin = $mydomain
inet_interfaces = all
inet_protocols = ipv4
home_mailbox = Maildir/
mydestination = $myhostname, example.com, localhost.localdomain, localhost
smtpd_tls_cert_file=/etc/letsencrypt/live/mail.example.com/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.example.com/privkey.pem
smtpd_use_tls=yes
EOF

"$SU" systemctl restart postfix

test -f /etc/dovecot/dovecot.conf || "$SU" rm /etc/dovecot/dovecot.conf

cat << EOF | "$SU" tee -a /etc/dovecot/dovecot.conf
protocols = imap
mail_location = maildir:~/Maildir
ssl_cert = </etc/letsencrypt/live/mail.example.com/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.example.com/privkey.pem
EOF

"$SU" systemctl restart dovecot

"$SU" certbot certonly --standalone -d mail.example.com
"$SU" crontab -e
0 3 * * * "$SU" certbot renew --quiet && "$SU" systemctl reload postfix dovecot

"$SU" mailman info
"$SU" mailman create list@example.com

test -f /etc/mailman.cfg || "$SU" rm /etc/mailman.cfg
cat << EOF | "$SU" tee -a /etc/mailman.cfg
[mailman]
site_owner: admin@example.com
EOF

"$SU" systemctl enable mailman
"$SU" systemctl start mailman

"$SU" ln -s /var/lib/mailman/archives/private /opt/mail_archive

"$SU" apt install python3-postorius python3-hyperkitty
cat << EOF | "$SU" tee -a /etc/mailman-web/settings.py
SECRET_KEY = 'your-secret-key'
DEBUG = False
ALLOWED_HOSTS = ['example.com']
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/var/lib/mailman-web/data/mailman-web.sqlite',
    }
}
EOF

"$SU" python3 manage.py migrate
"$SU" python3 manage.py createsuperuser
"$SU" python3 manage.py runserver 0.0.0.0:8000


