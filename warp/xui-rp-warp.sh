#!/bin/bash

curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
apt-get update && apt-get install cloudflare-warp -y
wget https://pkg.cloudflareclient.com/pool/$(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2)/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb > /dev/null 2>&1
dpkg -i cloudflare-warp_2024.6.497-1_amd64.deb

warp-cli status
#echo -e "yes" | warp-cli --accept-tos registration new
#warp-cli --accept-tos mode proxy
#warp-cli --accept-tos proxy port 40000
#warp-cli --accept-tos connect
#yes | warp-cli registration new
warp-cli --accept-tos registration new
warp-cli mode proxy
warp-cli proxy port 40000
warp-cli connect

rm -rf cloudflare-warp_*
mkdir -p /etc/systemd/system/warp-svc.service.d

cat > /etc/systemd/system/warp-svc.service.d/override.conf <<EOF
[Service]
LogLevelMax=3
EOF

systemctl daemon-reload
systemctl restart warp-svc.service

sleep 5
curl -x socks5h://localhost:40000 https://2ip.io
warp-cli tunnel stats
