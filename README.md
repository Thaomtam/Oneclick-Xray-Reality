# Xray-reality
This is a Bash script that installs Xray Beta and downloads the configuration for the repository created by [dailyhbd](https://www.youtube.com/channel/UCk6D0n5Xy6EN16AE2g6q0uQ) for ViệtNam inside this repository with your own key and places it only with one command 😏
#
## Installation h2+reality
```
 bash -c "$(curl -L https://raw.githubusercontent.com/Thaomtam/Oneclick-Xray-Reality/main/h2.sh?token=GHSAT0AAAAAACHFDCR2CLR6H7OYFAGX7I2YZHYKDEA)"
```
## Installation vision+reality
```
 bash -c "$(curl -L https://raw.githubusercontent.com/Thaomtam/Oneclick-Xray-Reality/main/vision.sh?token=GHSAT0AAAAAACHFDCR2W4S7TT3ZY2WBMLWWZHYKFBA)"
```
## Installation Socks Proxy
```
 bash -c "$(curl -L https://raw.githubusercontent.com/Thaomtam/Oneclick-Xray-Reality/main/socks.sh)"
```

# Linux-NetSpeed
```
wget -O tcp.sh "https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```
| Dự án | |
| :--- | :--- |
| Chương trình | **/usr/local/bin/xray** |
| Cấu hình | **/usr/local/etc/xray/config.json** |
| Nghiên cứu | `xray -test -config /usr/local/etc/xray/config.json` |
| Xem nhật kí | `journalctl -u xray --output cat -e` |
| Nhật ký thời gian thực | `journalctl -u xray --output cat -f` |
