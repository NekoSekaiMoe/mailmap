#!/bin/bash

set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    SU=""
else
    SU="sudo"
fi

echo "==> 配置 Mailman..."
$SU dpkg-reconfigure mailman3

cat << EOF | $SU tee /etc/mailman3/mailman.cfg
[mailman]
site_owner: admin@example.com
EOF

$SU systemctl restart mailman3

