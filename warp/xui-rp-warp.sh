#!/bin/bash

# Установка ключа и репозитория Cloudflare WARP
# curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
# apt-get update && apt-get install cloudflare-warp -y

export DEBIAN_FRONTEND=noninteractive

# Скачиваем и устанавливаем пакет Cloudflare WARP
wget https://pkg.cloudflareclient.com/pool/$(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2)/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb -O /tmp/cloudflare-warp_2024.6.497-1_amd64.deb > /dev/null 2>&1
apt install -y /tmp/cloudflare-warp_2024.6.497-1_amd64.deb

# Удаление временных файлов
rm -rf /tmp/cloudflare-warp_*

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
systemctl status warp-svc

# Запуск команд с соглашением об условиях
warp-cli --accept-tos registration new
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect

echo
sleep 5
warp-cli tunnel stats
curl -x socks5h://localhost:40000 https://2ip.io
echo

# Проверка кода возврата
if [ $? -eq 0 ]; then
    echo "Настройка завершена: WARP подключен и работает."
else
    echo "Ошибка: не удалось подключиться к WARP через прокси. Пожалуйста, проверьте настройки."
fi