#!/bin/bash

# Install snapd
apt update -y && \
apt install -y snapd

# Ask for domain
read -p "Enter your domain: " domain

# Ask for port
read -p "Enter your port: " port

# Ask for user
read -p "Enter user: " user

# Ask for password
read -p "Enter password: " password

# Install certbot
snap install core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# Obtain SSL certificate
certbot certonly --standalone --register-unsafely-without-email -d $domain

# Copy SSL certificate files
cp /etc/letsencrypt/archive/*/fullchain*.pem /etc/ssl/private/fullchain.cer
cp /etc/letsencrypt/archive/*/privkey*.pem /etc/ssl/private/private.key
chown -R nobody:nogroup /etc/ssl/private
chmod -R 0644 /etc/ssl/private/*

# Schedule automatic renewal
printf "0 0 1 * * /root/update_certbot.sh\n" > update && crontab update && rm update
cat > /root/update_certbot.sh << EOF
#!/usr/bin/env bash
certbot renew --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
cp /etc/letsencrypt/archive/*/fullchain*.pem /etc/ssl/private/fullchain.cer
cp /etc/letsencrypt/archive/*/privkey*.pem /etc/ssl/private/private.key
EOF
chmod +x update_certbot.sh

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta

json=$(curl -s https://raw.githubusercontent.com/Thaomtam/Oneclick-Xray-Reality/main/socks.yaml)

port=$port
user=$user
password=$password

newJson=$(echo "$json" | jq \
    --arg port "$port" \
    --arg user "$user" \
    --arg password "$password" \
    '.inbounds[0].port= ['$port'] |
     .inbounds[0].settings.accounts.user = ["'$user'"] |
     .inbounds[0].settings.accounts.pass = ["'$password'"] |
echo "$newJson" | sudo tee /usr/local/etc/xray/config.json >/dev/null

# Configure Geoip
curl -Lo /usr/local/share/xray/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat && \
systemctl restart xray

# Ask for time zone
sysctl -w net.core.rmem_max=16777216 && \
sysctl -w net.core.wmem_max=16777216

exit 0
