#!/bin/bash

set -x

sudo systemctl daemon-reload
sudo systemctl enable crow_mail
sudo systemctl start crow_mail
sudo ln -s /etc/nginx/sites-available/crow_mail /etc/nginx/sites-enabled/
sudo systemctl restart nginx

