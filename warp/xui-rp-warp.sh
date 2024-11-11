#!/bin/bash

echo -e "yes" | warp-cli --accept-tos registration new
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect
mkdir -p /etc/systemd/system/warp-svc.service.d
cat > /etc/systemd/system/warp-svc.service.d/override.conf <<EOF
[Service]
LogLevelMax=3
EOF
systemctl daemon-reload
systemctl restart warp-svc.service
