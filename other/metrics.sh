1. Установка и настройка необходимых компонентов
Перед тем как начать, убедитесь, что у вас установлены необходимые компоненты:

node_exporter — для сбора метрик.
Pushgateway — для сбора метрик и их сохранения.
systemd — для управления периодическим запуском.
2. Установка node_exporter и Pushgateway
Установите node_exporter (если он еще не установлен):

Для Debian/Ubuntu:


sudo apt update
sudo apt install prometheus-node-exporter
Установите Pushgateway:

Для Debian/Ubuntu:


sudo apt install prometheus-pushgateway
Или можно скачать и запустить последнюю версию с официального сайта Prometheus.

3. Создание скрипта для сбора метрик и отправки в Pushgateway
Создайте скрипт, который будет собирать метрики с node_exporter и отправлять их в Pushgateway.

Откройте редактор и создайте скрипт:


sudo nano /usr/local/bin/push_metrics.sh
Вставьте следующий код в скрипт:


#!/bin/bash

# Сбор метрик (например, с node_exporter)
curl -s http://localhost:9100/metrics > /tmp/node_metrics.txt

# Отправка метрик в Pushgateway
curl -X POST --data @/tmp/node_metrics.txt http://localhost:9091/metrics/job/node_exporter
Сделайте скрипт исполнимым:


sudo chmod +x /usr/local/bin/push_metrics.sh
4. Создание юнита systemd для скрипта
Создайте файл юнита для systemd, чтобы запускать скрипт.


sudo nano /etc/systemd/system/push_metrics.service
Вставьте следующее содержимое:

ini
Копировать код
[Unit]
Description=Push metrics to Pushgateway every 10 seconds
After=network.target

[Service]
ExecStart=/usr/local/bin/push_metrics.sh
Restart=always
User=prometheus
Group=prometheus
WorkingDirectory=/var/lib/prometheus
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
Перезагрузите systemd, чтобы применить изменения:


sudo systemctl daemon-reload
5. Настройка таймера systemd для запуска каждые 10 секунд
Создайте таймер для запуска скрипта каждые 10 секунд.

Создайте файл таймера:


sudo nano /etc/systemd/system/push_metrics.timer
Вставьте следующее содержимое:

ini
Копировать код
[Unit]
Description=Run Push metrics script every 10 seconds

[Timer]
OnBootSec=10sec
OnUnitActiveSec=10sec

[Service]
Unit=push_metrics.service
Перезагрузите systemd и активируйте таймер:


sudo systemctl daemon-reload
sudo systemctl enable push_metrics.timer
sudo systemctl start push_metrics.timer
6. Проверка работы
Проверьте, что сервис и таймер работают корректно:


sudo systemctl status push_metrics.service
sudo systemctl status push_metrics.timer
Проверьте логи, чтобы убедиться, что метрики успешно отправляются в Pushgateway:


journalctl -u push_metrics.service -f
7. Резюме
Теперь у вас настроен скрипт, который каждые 10 секунд будет собирать метрики с node_exporter и отправлять их в Pushgateway. Мы настроили его с использованием systemd и systemd.timer, чтобы запускать скрипт каждые 10 секунд.

Таким образом, скрипт не содержит циклов с sleep, и система управляет периодичностью запуска скрипта, что более эффективно и стабильно.



global:
  scrape_interval: 15s  # Интервал опроса метрик

scrape_configs:
  # Сбор метрик с Pushgateway
  - job_name: 'pushgateway'
    honor_labels: true
    static_configs:
      - targets: ['localhost:9091']  # Адрес вашего Pushgateway
    basic_auth:
      username: "yourusername"  # Имя пользователя для базовой аутентификации
      password: "yourpassword"  # Пароль для базовой аутентификации


