#!/bin/bash

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
