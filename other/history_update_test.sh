#!/bin/bash

get_download_count() {
    REPO_OWNER="cortez24rus"     # Имя владельца репозитория
    REPO_NAME="xui-reverse-proxy" # Имя репозитория
    FILE_PATH="other/history_update.sh" # Путь к файлу
    RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/main/${FILE_PATH}"

    # Логирование запросов
    curl -X POST -H "Content-Type: application/json" -d '{"event": "script_downloaded"}' \
        "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/traffic/views" > /dev/null 2>&1

    # Информация о скачивании
    DOWNLOAD_COUNT=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/traffic/views" | jq '.count')

    echo "Количество скачиваний скрипта: $DOWNLOAD_COUNT"
}

get_download_count

history_file="/var/log/apt/history.log"

# Извлекаем последнюю дату обновления
last_upgrade_date=$(grep "Start-Date:" "$history_file" | awk '{print $2}' | sort -r | head -n 1)
if [ -z "$last_upgrade_date" ]; then
    echo "Не удалось извлечь дату последнего обновления."
    exit 1
fi

# Текущая дата
current_date=$(date +%Y-%m-%d)

# Разница в днях
days_diff=$(( ( $(date -d "$current_date" +%s) - $(date -d "$last_upgrade_date" +%s) ) / 86400 ))

echo $last_upgrade_date
echo $days_diff

# Проверяем разницу
if [ $days_diff -le 3 ]; then
    echo "Система обновлена."
else
    echo "Система не обновлялась более 3-х дней."
fi
