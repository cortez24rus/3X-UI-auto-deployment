#!/bin/bash

# Установка ключа и репозитория Cloudflare WARP
# curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
# apt-get update && apt-get install cloudflare-warp -y

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/xui-rp/

echo "Попытка скачать пакет..."
while ! wget --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://pkg.cloudflareclient.com/pool/$(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2)/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb" -O /usr/local/xui-rp/cloudflare-warp_2024.6.497-1_amd64.deb; do
    echo "Не удалось скачать. Повторная попытка через 3 секунды..."
    sleep 3
done
echo "Скачивание завершено успешно."

cd /usr/local/xui-rp/
apt install -y ./cloudflare-warp_2024.6.497-1_amd64.deb
rm -rf cloudflare-warp_*
cd ~/

# Создание директории для конфигурации
mkdir -p /etc/systemd/system/warp-svc.service.d

# Настройка уровня логирования
cat > /etc/systemd/system/warp-svc.service.d/override.conf <<EOF
[Service]
LogLevelMax=3
EOF
echo

# Перезагрузка демона и ожидание его запуска
systemctl daemon-reload
systemctl restart warp-svc.service
sleep 5  # Ожидание запуска демона

systemctl status warp-svc || echo "Служба warp-svc не найдена или не запустилась."

# Удаление старых данных и сброс регистрации
warp-cli --accept-tos disconnect || true
warp-cli --accept-tos registration delete || true

# Регистрация с автоматическим подтверждением
script -q -c "echo y | warp-cli registration new"

# Настройка прокси-режима
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect

echo
sleep 5
warp-cli tunnel stats

if curl -x socks5h://localhost:40000 https://2ip.io; then
    echo "Настройка завершена: WARP подключен и работает."
else
    echo "Ошибка: не удалось подключиться к WARP через прокси. Проверьте настройки."
fi