#!/bin/bash

history_file="/var/log/apt/history.log"
last_upgrade_date=$(grep "Start-Date:" $history_file | head -n 1 | awk '{print $2, $3, $4}')
last_upgrade_timestamp=$(date -d "$last_upgrade_date" +%s)
current_timestamp=$(date +%s)
days_diff=$(( (current_timestamp - last_upgrade_timestamp) / 86400 ))

if [ $days_diff -le 3 ]; then
    echo "Система обновлена."
else
    echo "Система не обновлялась более 3-х дней."
fi
