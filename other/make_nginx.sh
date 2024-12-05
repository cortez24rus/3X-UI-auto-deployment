#!/bin/bash

sudo apt update && apt install -y \
    build-essential \
    libpcre++-dev \
    libssl-dev \
    libgeoip-dev \
    libxslt1-dev \
    zlib1g-dev \
    libgd-dev \
    libmaxminddb0 \
    libmaxminddb-dev \
    mmdb-bin \
    git

NGINX_VERSION="1.27.3"
wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
tar -xvf nginx-$NGINX_VERSION.tar.gz
cd nginx-$NGINX_VERSION
git clone https://github.com/leev/ngx_http_geoip2_module.git

./configure \
    --sbin-path=/usr/sbin/nginx \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/run/nginx.lock \
    --pid-path=/run/nginx.pid \
    --modules-path=/usr/lib/nginx/modules \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_gunzip_module \
    --add-dynamic-module=./ngx_http_geoip2_module
#    --with-compat \
#    --with-pcre-jit \
#    --with-http_dav_module \
#    --with-http_slice_module \
#    --with-threads \
#    --with-http_addition_module \
#    --with-http_image_filter_module=dynamic \
#    --with-http_sub_module \
#    --with-http_xslt_module=dynamic \

make
make install

mkdir -p /var/lib/nginx/body
chown -R www-data:www-data /var/lib/nginx
chmod -R 700 /var/lib/nginx

cat > /etc/systemd/system/nginx.service <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
        
[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
        
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start nginx
sudo systemctl enable nginx

cd ..
sudo rm -rf nginx-$NGINX_VERSION.tar.gz nginx-$NGINX_VERSION ngx_http_geoip2_module

systemctl status nginx
nginx -v
