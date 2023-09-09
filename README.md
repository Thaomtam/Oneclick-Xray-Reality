# Xray-reality
This is a Bash script that installs Xray Beta and downloads the configuration for the repository created by [dailyhbd](https://www.youtube.com/channel/UCk6D0n5Xy6EN16AE2g6q0uQ) for ViệtNam inside this repository with your own key and places it only with one command 😏
#
## Tập lệnh cài đặt wireguard 1 cú nhấp
```
curl -sLo warp-reg https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 && chmod +x warp-reg && ./warp-reg && rm warp-reg
```
## Installation VLESS-H2-uTLS-REALITY
```
 LH MUA QUA ZALO 0326 333 473
```
## Installation VLESS-XTLS-uTLS-REALITY
```
 LH MUA QUA ZALO 0326 333 473
```
## Installation Socks Proxy
```
 LH MUA QUA ZALO 0326 333 473
```

# Linux-NetSpeed (Tăng tốc vps)
```
 LH MUA QUA ZALO 0326 333 473
```
| | Không cần phải đăng ký tên miền | Giải quyết TLS trong TLS | Tích hợp đa kênh | Truy cập qua CDN |
| :--- | :---: | :---: | :---: | :---: |
| **VLESS-XTLS-Vision** | :x: | :heavy_check_mark: | :x: | :x: |
| **VLESS-XTLS-uTLS-REALITY** | :heavy_check_mark: | :heavy_check_mark: | :x: | :x: |
| **VLESS-gRPC-uTLS-REALITY** | :heavy_check_mark: | :x: | :heavy_check_mark: | :x: |
| **VLESS-H2-uTLS-REALITY** | :heavy_check_mark: | :x: | :heavy_check_mark: | :x: |
| **VLESS-gRPC** | :x: | :x: | :heavy_check_mark: | :heavy_check_mark: |

| Dự án | |
| :--- | :--- |
| Chương trình | **/usr/local/bin/xray** |
| Cấu hình | **/usr/local/etc/xray/config.json** |
| Nghiên cứu | `xray -test -config /usr/local/etc/xray/config.json` |
| Xem nhật kí | `journalctl -u xray --output cat -e` |
| Nhật ký thời gian thực | `journalctl -u xray --output cat -f` |
{
  "log": {
    "access": "none",
    "loglevel": "error",
    "dnsLog": true
  },
  "inbounds": [
    {
      "tag": "proxy-in",
      "port": 9898,
      "protocol": "dokodemo-door",
      "settings": {
        "network": "tcp,udp",
        "followRedirect": true
      },
      "streamSettings": {
        "sockopt": {
          "tproxy": "tproxy"
        }
      },
      "sniffing": {
        "enabled": true,
        "routeOnly": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "27.71.235.169",
            "port": 443,
            "users": [
              {
                "id": "thoitiet.github",
                "flow": "xtls-rprx-vision",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "fingerprint": "chrome",
          "serverName": "dl.kgvn.garenanow.com",
          "publicKey": "BMVrtf_T_ohjCaCA8UCWcJqwCQGOP0JTK1CjJAEks2s",
          "shortId": "4e6d88f5d484a17a",
          "spiderX": "/"
        }
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIP"
      }
    },
    {
      "protocol": "blackhole",
      "settings": {
        "response": {
          "type": "http"
        }
      },
      "tag": "block"
    },
    {
      "tag": "dns-out",
      "protocol": "dns",
      "settings": {
        "address": "1.1.1.1"
      }
    }
  ],
  "dns": {
    "hosts": {},
    "servers": [
      "1.1.1.1"
    ],
    "tag": "dns",
    "queryStrategy": "UseIP"
  },
  "routing": {
        "domainMatcher": "mph",
        "domainStrategy": "IPIfNonMatch",
        "rules": [
            {
                "inboundTag": [
                    "proxy-in"
                ],
                "outboundTag": "dns-out",
                "port": 53,
                "type": "field"
            },
            {
                "domain": [
                    "geosite:category-ads-all",
                    "keyword:ads"
                ],
                "outboundTag": "block",
                "type": "field"
            },
            {
                "domain": [
                    "regexp:^.*googlesyndication.com$",
                    "regexp:^.*adtival\\.network$"
                ],
                "outboundTag": "proxy",
                "type": "field"
            },
            {
                "domain": [
                    "geosite:youtube"
                ],
                "network": "udp",
                "outboundTag": "block",
                "type": "field"
            },
            {
                "network": "tcp,udp",
                "outboundTag": "proxy",
                "type": "field"
            }
        ]
    }
}