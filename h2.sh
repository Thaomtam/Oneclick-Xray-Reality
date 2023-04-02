# Update package index and install dependencies
apt-get update
apt-get install -y jq
apt-get install -y openssl
apt-get install -y qrencode

read -p "Enter serverNames: " sni

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta

json=$(curl -s https://raw.githubusercontent.com/Thaomtam/h2reality-install/main/config.json)

keys=$(xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ifconfig.me)
uuid=$(xray uuid)
shortId=$(openssl rand -hex 8)
sni=$sni
url="vless://$uuid@$serverIp:443?path=%2F&security=reality&encryption=none&pbk=$pub&fp=chrome&type=http&sni=$sni&sid=$shortId#REALITY"

newJson=$(echo "$json" | jq \
    --arg sni "$sni" \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    '.inbounds[0].streamSettings.realitySettings.privateKey = $pk | 
     .inbounds[0].streamSettings.realitySettings.serverNames = ["'$sni'"] |
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.shortIds += ["'$shortId'"]')
echo "$newJson" | sudo tee /usr/local/etc/xray/config.json >/dev/null

# Configure Nginx & Geosite and Geoip
curl -Lo /usr/local/share/xray/geoip.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat && curl -Lo /usr/local/share/xray/geosite.dat https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat && systemctl restart xray

# Ask for time zone
timedatectl set-timezone Asia/Ho_Chi_Minh && \
apt install ntp && \
timedatectl set-ntp on

echo "$url"

qrencode -s 120 -t ANSIUTF8 "$url"
qrencode -s 50 -o qr.png "$url"

exit 0
