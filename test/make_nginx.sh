#!/bin/bash

apt update && apt install -y \
  git \
  build-essential \
  libpcre2-dev \
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
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --add-dynamic-module=./ngx_http_geoip2_module \
    --with-cc-opt="-g -O2 -ffile-prefix-map=$(pwd)/${NGINX_VERSION}=${PWD}/${NGINX_VERSION} -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC" \
    --with-ld-opt="-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie"

make
make install

mkdir -p /var/cache/nginx/
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
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/sh -c "/bin/kill -s HUP $(/bin/cat /run/nginx.pid)"
ExecStop=/bin/sh -c "/bin/kill -s TERM $(/bin/cat /run/nginx.pid)"
#PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
systemctl status nginx --no-pager
cd ..
sudo rm -rf nginx-$NGINX_VERSION.tar.gz nginx-$NGINX_VERSION ngx_http_geoip2_module