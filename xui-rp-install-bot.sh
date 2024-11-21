#!/bin/bash

# Пример использования токена
if [[ -z "$1" || ! "$1" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]]; then
    echo "Неверный формат токена! Токен должен быть в формате '123456789:AAHt-D8V4kM6rmV0TjQjYaS8B6h54gZ5GrY'"
    exit 1
fi

# Установка необходимых пакетов
apt-get update && apt-get install -y python3 python3-pip python3-venv curl || { echo "Ошибка установки пакетов"; exit 1; }

# Очистка предыдущих файлов
[ -f /usr/local/xui-rp/xui-rp-bot.py ] && rm /usr/local/xui-rp/xui-rp-bot.py
[ -f /usr/local/xui-rp/xui-rp-env ] && rm -rf /usr/local/xui-rp/xui-rp-env
[ -f /etc/systemd/system/xui-rp-bot.service ] && rm /etc/systemd/system/xui-rp-bot.service

systemctl disable xui-rp-bot.service >/dev/null
systemctl stop xui-rp-bot.service >/dev/null
systemctl daemon-reload >/dev/null

# Создание директории и виртуального окружения
mkdir -p /usr/local/xui-rp/
python3 -m venv /usr/local/xui-rp/xui-rp-env || { echo "Ошибка создания виртуального окружения"; exit 1; }

# Путь к конфигурационному файлу
CONFIG_FILE="/usr/local/xui-rp/xui-rp-bot-config.json"

# Создаем или обновляем конфигурационный файл
cat > $CONFIG_FILE <<EOF
{
  "BOT_TOKEN": "$1",
  "BOT_AID": $2,
  "NAME_MENU": "🎛 $3 🎛"
}
EOF

# Активируем окружение и устанавливаем зависимости
source /usr/local/xui-rp/xui-rp-env/bin/activate
pip install requests python-telegram-bot || { echo "Ошибка установки зависимостей"; exit 1; }
deactivate

# Загрузка файла с проверкой с помощью wget
while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused https://raw.githubusercontent.com/cortez24rus/xui-reverse-proxy/refs/heads/main/bot/xui-rp-bot.py -O /usr/local/xui-rp/xui-rp-bot.py; do
    echo "Скачивание не удалось, пробуем снова..."
    sleep 3
done

# Демон xui бота
cat > /etc/systemd/system/xui-rp-bot.service <<EOF
[Unit]
Description=Xui Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/xui-rp/
ExecStart=/usr/local/xui-rp/xui-rp-env/bin/python /usr/local/xui-rp/xui-rp-bot.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Перезагружаем systemd и запускаем службу
systemctl enable xui-rp-bot.service || { echo "Ошибка при отключении службы"; exit 1; }
systemctl start xui-rp-bot.service || { echo "Ошибка при остановке службы"; exit 1; }
systemctl daemon-reload || { echo "Ошибка при перезагрузке systemd"; exit 1; }
