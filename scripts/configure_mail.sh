#!/bin/bash

set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    SU=""
else
    SU="sudo"
fi

echo "==> 配置 Postfix..."
cat << EOF | $SU tee /etc/postfix/main.cf
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

$SU systemctl restart postfix

echo "==> 配置 Dovecot..."
cat << EOF | $SU tee /etc/dovecot/dovecot.conf
protocols = imap
mail_location = maildir:~/Maildir
ssl_cert = </etc/letsencrypt/live/mail.example.com/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.example.com/privkey.pem
EOF

$SU systemctl restart dovecot

