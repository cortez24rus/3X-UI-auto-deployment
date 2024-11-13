#!/bin/bash

# Обновляем пакеты и устанавливаем зависимости
sudo apt-get update && sudo apt-get install -y build-essential \
libpcre3 \
libpcre3-dev \
zlib1g \
zlib1g-dev \
libssl-dev

# Загружаем и распаковываем Nginx
wget https://nginx.org/download/nginx-1.26.2.tar.gz
if [ $? -ne 0 ]; then
    echo "Ошибка при загрузке nginx-1.26.2.tar.gz"
    exit 1
fi

tar -xzvf nginx-1.26.2.tar.gz
cd nginx-1.26.2 || exit

# Конфигурируем и устанавливаем Nginx
./configure --with-http_ssl_module --with-http_v2_module --with-stream --with-stream_ssl_module --with-http_stub_status_module --with-http_gzip_static_module
if [ $? -ne 0 ]; then
    echo "Ошибка при конфигурации Nginx"
    exit 1
fi

make
if [ $? -ne 0 ]; then
    echo "Ошибка при компиляции Nginx"
    exit 1
fi

sudo make install

# Запускаем Nginx
sudo /usr/local/nginx/sbin/nginx

# Добавляем путь Nginx в PATH и сохраняем его в bashrc
export PATH=$PATH:/usr/local/nginx/sbin
echo 'export PATH=$PATH:/usr/local/nginx/sbin' >> ~/.bashrc
source ~/.bashrc

# Создаем файл systemd для Nginx
sudo bash -c 'cat > /etc/systemd/system/nginx.service <<EOF
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop
PIDFile=/usr/local/nginx/logs/nginx.pid

[Install]
WantedBy=multi-user.target
EOF'

# Перезагружаем systemd и включаем Nginx
sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl start nginx

# Проверяем статус Nginx
sudo systemctl status nginx
