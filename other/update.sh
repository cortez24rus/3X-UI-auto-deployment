#!/bin/bash

history_file="/var/log/apt/history.log"
# Извлекаем последнюю дату обновления
last_upgrade_date=$(grep "Start-Date:" $history_file | tail -n 1 | awk '{print $2, $3}')
last_upgrade_time=$(grep "Start-Date:" $history_file | tail -n 1 | awk '{print $4}')
echo $last_upgrade_date
echo $last_upgrade_time

# Преобразуем дату и время в timestamp
last_upgrade_timestamp=$(date -d "${last_upgrade_date} ${last_upgrade_time}" +%s 2>/dev/null)
if [ -z "$last_upgrade_timestamp" ]; then
    echo "Не удалось извлечь дату последнего обновления."
    exit 1
fi

echo $last_upgrade_timestamp

# Текущая дата в timestamp
current_timestamp=$(date +%s)

# Разница в днях
days_diff=$(( (current_timestamp - last_upgrade_timestamp) / 86400 ))

echo $days_diff

if [ $days_diff -le 3 ]; then
    echo "Система обновлена."
else
    echo "Система не обновлялась более 3-х дней."
fi
