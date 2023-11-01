#!/bin/bash

# Update package repositories
apt update -y

# Input: Domain, SNI, and UUID
read -p "Enter your domain: " domain
read -p "Enter your SNI: " sni
read -p "Enter your UUID: " id

# Install necessary tools
apt install -y socat jq openssl qrencode

# Install acme.sh for SSL certificate management
curl https://get.acme.sh | sh
source ~/.bashrc
acme.sh --upgrade --auto-upgrade
acme.sh --set-default-ca --server letsencrypt
chown -R nobody:nogroup /etc/ssl/private
acme.sh --issue -d "$domain" --standalone --keylength ec-256
acme.sh --install-cert -d "$domain" --ecc \
--fullchain-file /etc/ssl/private/fullchain.cer \
--key-file /etc/ssl/private/private.key

# Install Nginx
apt install -y gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor > /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" > /etc/apt/preferences.d/99nginx
apt update -y
apt install -y nginx
mkdir -p /etc/systemd/system/nginx.service.d
echo -e "[Service]\nExecStartPost=/bin/sleep 0.1" > /etc/systemd/system/nginx.service.d/override.conf
systemctl daemon-reload

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version v1.8.3

# Configure Xray with input data
json=$(curl -s https://raw.githubusercontent.com/Thaomtam/Oneclick-Xray-Reality/main/VLESS-XTLS-uTLS-REALITY.json)
keys=$(xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$domain
shortId=$(openssl rand -hex 8)
url="vless://$id@$serverIp:443?security=reality&encryption=none&pbk=$pub&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=$sni&sid=$shortId#Thời-Tiết-Openwrt"

# Update Xray configuration file
newJson=$(echo "$json" | jq \
    --arg sni "$sni" \
    --arg pk "$pk" \
    --arg uuid "$id" \
    '.inbounds[0].streamSettings.realitySettings.privateKey = $pk | 
    .inbounds[0].streamSettings.realitySettings.serverNames = ["'$sni'"] |
    .inbounds[0].settings.clients[0].id = $uuid |
    .inbounds[0].streamSettings.realitySettings.shortIds += ["'$shortId'"]')
echo "$newJson" | sudo tee /usr/local/etc/xray/config.json >/dev/null

# Configure Nginx & Geosite and Geoip
curl -Lo /usr/local/share/xray/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat
curl -Lo /usr/local/share/xray/geosite.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat
curl -Lo /etc/nginx/nginx.conf https://raw.githubusercontent.com/Thaomtam/Oneclick-Xray-Reality/main/nginx.conf
systemctl restart xray
systemctl restart nginx

# Set timezone and network parameters
timedatectl set-timezone Asia/Ho_Chi_Minh
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

# Generate URL and QR Code
echo "Generated URL: $url"
qrencode -s 120 -t ANSIUTF8 "$url"
qrencode -s 50 -o qr.png "$url"

exit 0
