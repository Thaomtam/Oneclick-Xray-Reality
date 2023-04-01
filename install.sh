#!/bin/bash

# Ask for domain
read -p "Enter your domain name: " domain

# Ask for SNI
read -p "Enter serverNames: " sni

# Ask for SNI
read -p "Enter uuid: " id

# Install snapd
apt update -y && \
apt install -y snapd

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

# Install Nginx
apt install -y gnupg2 ca-certificates lsb-release ubuntu-keyring && curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor > /usr/share/keyrings/nginx-archive-keyring.gpg && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" > /etc/apt/sources.list.d/nginx.list && echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" > /etc/apt/preferences.d/99nginx && apt update -y && apt install -y nginx && mkdir -p /etc/systemd/system/nginx.service.d && echo -e "[Service]\nExecStartPost=/bin/sleep 0.1" > /etc/systemd/system/nginx.service.d/override.conf && systemctl daemon-reload

# Configure Nginx & Geosite and Geoip
curl -Lo /usr/local/share/xray/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat && curl -Lo /usr/local/share/xray/geosite.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat
systemctl restart nginx
# Update package index and install dependencies
apt-get install -y jq
apt-get install -y openssl
apt-get install -y qrencode

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta

json=$(curl -s https://raw.githubusercontent.com/Thaomtam/h2reality-install/main/config.json)

keys=$(xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ifconfig.me)
uuid=$id
shortId=$(openssl rand -hex 8)
sni=$sni
url="vless://$uuid@$serverIp:443?path=%2F&security=reality&encryption=none&pbk=$pub&fp=chrome&type=http&sni=$sni&sid=$shortId#THAOMTAM-REALITY"

newJson=$(echo "$json" | jq \
    --arg sni "$sni" \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    '.inbounds[0].streamSettings.realitySettings.privateKey = $pk | 
     .inbounds[0].streamSettings.realitySettings.serverNames = ["'$sni'"] |
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.shortIds += ["'$shortId'"]')
echo "$newJson" | sudo tee /usr/local/etc/xray/config.json >/dev/null

systemctl restart xray 

# Ask for time zone
timedatectl set-timezone Asia/Ho_Chi_Minh && \
apt install ntp && \
timedatectl set-ntp on

echo "$url"

qrencode -s 120 -t ANSIUTF8 "$url"
qrencode -s 50 -o qr.png "$url"

exit 0
