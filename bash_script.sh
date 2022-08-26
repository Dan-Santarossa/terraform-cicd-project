#!/bin/bash

sudo apt update -y
sudo apt install nginx -y
systemctl start nginx
systemctl enable nginx
echo "RED TEAM TWO-TIER/CICD PROJECT" > /var/www/html/index.html