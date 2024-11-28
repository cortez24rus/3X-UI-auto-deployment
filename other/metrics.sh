1. Установка и настройка необходимых компонентов
Перед тем как начать, убедитесь, что у вас установлены необходимые компоненты:
node_exporter — для сбора метрик.
Pushgateway — для сбора метрик и их сохранения.
systemd — для управления периодическим запуском.

2. Установка node_exporter и Pushgateway
Установите node_exporter (если он еще не установлен):
sudo apt update
sudo apt install prometheus-node-exporter
Установите Pushgateway:
sudo apt install prometheus-pushgateway

3. Создание скрипта для сбора метрик и отправки в Pushgateway
Создайте скрипт, который будет собирать метрики с node_exporter и отправлять их в Pushgateway.

sudo nano /usr/local/bin/push_metrics.sh

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

sudo nano /etc/systemd/system/push_metrics.timer

[Unit]
Description=Run Push metrics script every 10 seconds

[Timer]
OnBootSec=10sec
OnUnitActiveSec=10sec

[Service]
Unit=push_metrics.service

sudo systemctl daemon-reload
sudo systemctl enable push_metrics.timer
sudo systemctl start push_metrics.timer

6. Проверка работы
Проверьте, что сервис и таймер работают корректно:
sudo systemctl status push_metrics.service
sudo systemctl status push_metrics.timer

Проверьте логи, чтобы убедиться, что метрики успешно отправляются в Pushgateway:
journalctl -u push_metrics.service -f







wget https://github.com/prometheus/pushgateway/releases/download/v1.10.0/pushgateway-1.10.0.linux-amd64.tar.gz
tar -zxvf pushgateway-1.10.0.linux-amd64.tar.gz
mv pushgateway-1.10.0.linux-amd64/pushgateway /usr/local/bin/

sudo mkdir -p /var/lib/prometheus/pushgateway
sudo chown prometheus:prometheus /var/lib/prometheus/pushgateway

sudo nano /etc/systemd/system/pushgateway.service
[Unit]
Description=Prometheus Pushgateway
After=network.target

[Service]
ExecStart=/usr/local/bin/pushgateway --persistence.file=/var/lib/prometheus/pushgateway/metrics.db
User=prometheus
Restart=on-failure

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl enable pushgateway
sudo systemctl start pushgateway
sudo systemctl status pushgateway



