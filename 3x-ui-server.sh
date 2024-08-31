#!/bin/bash

blue='\033[1;36m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear='\033[0m'


### IP сервера ###
serverip=$(curl -s ipinfo.io/ip)


### Проверка рута ###
check_root() {
    if [[ $EUID -ne 0 ]]
    then
        echo ""
        echo -e "${red}Error: this script should be run as root${clear}"
        echo ""
        exit 1
    fi
}


### Начало установки ###
start_installation() {
	clear
	echo ""
	echo -e "${red}ВНИМАНИЕ!${clear}"
	echo "Перед запуском скрипта рекомендуется выполнить следующие действия:"
	echo -e "Обновить систему командой ${red}apt update && apt full-upgrade -y${clear}"
	echo -e "Перезагрузить сервер командой ${red}reboot${clear}"
	echo ""
	echo -e "${blue}Скрипт установки 3x-ui. Начать установку? Выберите опцию [y/N]${clear}"
	read answer
	cancel="${red}___Отмена___${clear}"
	
	if [[ $answer != "y" ]] && [[ $answer != "Y" ]]
	then
		echo ""
		echo -e ${cancel}
		echo ""
		exit
	fi
	echo ""
}


### Ввод данных ###
data_entry() {
	echo -e "${blue}Установка часового пояса${clear}"
	sleep 2
	dpkg-reconfigure tzdata
	
	echo -e "${blue}Введите имя пользователя:${clear}"
	read username
	echo ""
	echo -e "${blue}Введите пароль пользователя:${clear}"
	read password
	echo ""
	
	echo -e "${blue}Введите доменное имя под будете маскировать (Reality):${clear}"
	read reality
	echo ""
	echo -e "${blue}Введите свое доменое имя${clear}"
	read domain
	if [[ "$domain" == "www."* ]]
	then
		domain=${domain#"www."}
	fi
	echo ""
	
	echo -e "${blue}Введите порт панели:${clear}"
	read webPort
	echo ""
	echo -e "${blue}Введите путь до панели:${clear}"
	read webBasePath
	echo ""
	echo -e "${blue}Введите порт подписки:${clear}"
	read subPort
	echo ""
	echo -e "${blue}Введите путь до подписки:${clear}"
	read subPath
	echo ""
	echo -e "${blue}Введите путь до json подписки:${clear}"
	read subJsonPath
	echo ""
	
	echo -e "${blue}Введите вашу почту, зарегистрированную на Cloudflare:${clear}"
	read email
	echo ""
	echo -e "${blue}Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:${clear}"
	read cftoken
	echo ""
	
	webCertFile=/etc/letsencrypt/live/${domain}/fullchain.pem
	webKeyFile=/etc/letsencrypt/live/${domain}/privkey.pem
	subURI=https://${domain}/${subPath}/
	subJsonURI=https://${domain}/${subJsonPath}/
}


### Обновление системы и установка пакетов ###
installation_of_utilities() {
	echo -e "${blue}___Обновление___${clear}"
	apt-get update && apt-get upgrade -y
	echo ""
	
	echo -e "${blue}Установка пакета git${clear}"
	apt-get install git -y
	echo ""
	
	echo -e "${blue}Установка пакета wget${clear}"
	apt-get install wget -y
	echo ""
	
	echo -e "${blue}Установка пакета sudo${clear}"
	apt-get install sudo -y
	echo ""
	
	echo -e "${blue}Установка пакета nginx-full${clear}"
	apt-get install nginx-full -y
	echo ""
	
	echo -e "${blue}Установка пакета net-tools${clear}"
	apt-get install net-tools -y
	echo ""
	
	echo -e "${blue}Установка пакета gnupg2${clear}"
	apt-get install gnupg2 -y
	echo ""
	
	echo -e "${blue}Установка пакета sqlite3${clear}"
	apt-get install sqlite3 -y
	echo ""
	
	echo -e "${blue}Установка пакета ufw${clear}"
	apt-get install ufw -y
	echo ""
	
	echo -e "${blue}Установка пакета Warp${clear}"
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
	apt-get update && apt-get install cloudflare-warp -y
	echo ""
	
	echo -e "${blue}Установка пакета unattended-upgrades${clear}"
	apt-get install unattended-upgrades -y
	echo ""
	
	echo -e "${blue}Установка пакета certbot${clear}"
	apt-get install certbot -y
	echo ""
	
	echo -e "${blue}Установка пакета python3-certbot-dns-cloudflare${clear}"
	apt-get install python3-certbot-dns-cloudflare -y
	echo ""
	
	echo -e "${blue}Установка пакета systemd-resolved${clear}"
	apt-get install systemd-resolved -y
	echo ""
}


### Добавление пользователя ###
add_user() {
 	echo -e "${blue}Добавление пользователя${clear}"
	useradd -m -s $(which bash) -G sudo ${username}
	echo "${username}:${password}" | chpasswd
	mkdir -p /home/${username}/.ssh/
	touch /home/${username}/.ssh/authorized_keys
	chown ${username}: /home/${username}/.ssh
	chmod 700 /home/${username}/.ssh
	chown ${username}:${username} /home/${username}/.ssh/authorized_keys
	echo ${username}
	echo ""
}


### Безопасность ###
uattended_upgrade() {
	echo -e "${blue}Автоматическое обновление безопасности${clear}"
	echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
	echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
	dpkg-reconfigure -f noninteractive unattended-upgrades
	systemctl restart unattended-upgrades
	echo ""
}


### DoT systemd-resolved ###
dns_encryption() {
	echo -e "${blue}Настройка systemd-resolved (DoT)${clear}"
	echo "DNS=9.9.9.9"
	
	cat > /etc/systemd/resolved.conf <<EOF
	#  This file is part of systemd.
	#
	#  systemd is free software; you can redistribute it and/or modify it under the
	#  terms of the GNU Lesser General Public License as published by the Free
	#  Software Foundation; either version 2.1 of the License, or (at your option)
	#  any later version.
	#
	# Entries in this file show the compile time defaults. Local configuration
	# should be created by either modifying this file, or by creating "drop-ins" in
	# the resolved.conf.d/ subdirectory. The latter is generally recommended.
	# Defaults can be restored by simply deleting this file and all drop-ins.
	#
	# Use 'systemd-analyze cat-config systemd/resolved.conf' to display the full config.
	#
	# See resolved.conf(5) for details.
	
	[Resolve]
	# Some examples of DNS servers which may be used for DNS= and FallbackDNS=:
	# Cloudflare: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
	# Google:     8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
	# Quad9:      9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net
	DNS=9.9.9.9
	#FallbackDNS=
	Domains=~.
	DNSSEC=yes
	DNSOverTLS=yes
EOF

	systemctl restart systemd-resolved.service
	echo ""
}


### BBR ###
enable_bbr() {
	echo -e "${blue}Включение BBR${clear}"
	
	if [[ ! "$(sysctl net.core.default_qdisc)" == *"= fq" ]]
	then
	    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
	fi
	if [[ ! "$(sysctl net.ipv4.tcp_congestion_control)" == *"bbr" ]]
	then
	    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
	fi
}


### Отключение IPv6 ###
disable_ipv6() {
	echo -e "${blue}Отключение IPv6${clear}"
	interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')
	
	if [[ ! "$(sysctl net.ipv6.conf.all.disable_ipv6)" == *"= 1" ]]
	then
	        echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	fi
	if [[ ! "$(sysctl net.ipv6.conf.default.disable_ipv6)" == *"= 1" ]]
	then
	        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
	fi
	if [[ ! "$(sysctl net.ipv6.conf.lo.disable_ipv6)" == *"= 1" ]]
	then
	        echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
	fi
	if [[ ! "$(sysctl net.ipv6.conf.$interface_name.disable_ipv6)" == *"= 1" ]]
	then
	        echo "net.ipv6.conf.$interface_name.disable_ipv6 = 1" >> /etc/sysctl.conf
	fi
	
	sysctl -p
	echo ""
}


### WARP ###
warp() {
	echo -e "${blue}Настройка warp${clear}"
	yes | warp-cli registration new
	warp-cli mode proxy
	warp-cli connect
	echo ""
}


### СЕРТИФИКАТЫ ###
issuance_of_certificates() {
	echo -e "${blue}Выдача сертификатов${clear}"
	touch cloudflare.credentials
	chown root:root cloudflare.credentials
	chmod 600 cloudflare.credentials
	
	if [[ "$cftoken" =~ [A-Z] ]]
	then
	    echo "dns_cloudflare_api_token = ${cftoken}" >> /root/cloudflare.credentials
	else
	    echo "dns_cloudflare_email = ${email}" >> /root/cloudflare.credentials
	    echo "dns_cloudflare_api_key = ${cftoken}" >> /root/cloudflare.credentials
	fi
	
	certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.credentials --dns-cloudflare-propagation-seconds 30 --rsa-key-size 4096 -d ${domain},*.${domain} --agree-tos -m ${email} --no-eff-email --non-interactive
	
	{ crontab -l; echo "0 0 1 */2 * certbot -q renew"; } | crontab -
	echo "renew_hook = systemctl reload nginx" >> /etc/letsencrypt/renewal/${domain}.conf
	echo ""
}


### NGINX ###
nginx_setup() {
	echo -e "${blue}Настройка NGINX${clear}"
	mkdir -p /etc/nginx/stream-enabled/
	#touch /etc/nginx/.htpasswd
	
cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_protocol \$backend {
    default             \$https;
    ""                  ssh;
}
map \$ssl_preread_server_name \$https {
    ${reality}          reality;
    www.${domain}       trojan;
    ${domain}           web;
}
upstream reality        { server 127.0.0.1:7443; }
upstream trojan         { server 127.0.0.1:9443; }
upstream web            { server 127.0.0.1:46076; }
upstream ssh            { server 127.0.0.1:22; }

server {
    listen 443          reuseport;
    ssl_preread         on;
    proxy_pass          \$backend;
}
EOF
	
cat > /etc/nginx/nginx.conf <<EOF
user                              www-data;
pid                               /run/nginx.pid;
worker_processes                  auto;
worker_rlimit_nofile              65535;
error_log                         /var/log/nginx/error.log;

include                           /etc/nginx/modules-enabled/*.conf;

events {
    multi_accept                  on;
    worker_connections            65535;
}

http {
    ###
    sendfile                      on;
    tcp_nopush                    on;
    tcp_nodelay                   on;
    server_tokens                 off;
    log_not_found                 off;
    types_hash_max_size           2048;
    types_hash_bucket_size        64;
    client_max_body_size          16M;

    # timeout
    keepalive_timeout             60s;
    keepalive_requests            1000;
    reset_timedout_connection     on;

    # MIME
    include                       /etc/nginx/mime.types;
    default_type                  application/octet-stream;

    # SSL
    ssl_session_timeout           1d;
    ssl_session_cache             shared:SSL:10m;
    ssl_session_tickets           off;

    # Mozilla Intermediate configuration
    ssl_prefer_server_ciphers on;
    ssl_protocols                 TLSv1.2 TLSv1.3;
    ssl_ciphers                   TLS13_AES_128_GCM_SHA256:TLS13_AES_256_GCM_SHA384:TLS13_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305;

    # OCSP Stapling
    ssl_stapling                  on;
    ssl_stapling_verify           on;
    resolver                      1.1.1.1 valid=60s;
    resolver_timeout              2s;

    # access_log /var/log/nginx/access.log;
    gzip                          on;

    include /etc/nginx/conf.d/*.conf;
}

stream {
    include /etc/nginx/stream-enabled/stream.conf;
}
EOF

cat > /etc/nginx/conf.d/local.conf <<EOF
# HTTP redirect
server {
    listen 80 default_server;
    server_name _;
    return 301 https://${domain}\$request_uri;
}

# Main
server {
    listen                      46076 ssl default_server;

    # SSL
    ssl_reject_handshake        on;
    ssl_session_timeout         1h;
    ssl_session_cache           shared:SSL:10m;
}
server {
    listen                      46076 ssl http2;
    server_name                 ${domain} www.${domain};

    # SSL
    ssl_certificate             /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key         /etc/letsencrypt/live/${domain}/privkey.pem;
    ssl_trusted_certificate     /etc/letsencrypt/live/${domain}/chain.pem;

    # Security headers
    add_header X-XSS-Protection          "1; mode=block" always;
    add_header X-Content-Type-Options    "nosniff" always;
    add_header Referrer-Policy           "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy   "default-src https:; script-src https: 'unsafe-inline' 'unsafe-eval'; style-src https: 'unsafe-inline';" always;
    add_header Permissions-Policy        "interest-cohort=()" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options           "SAMEORIGIN";
    proxy_hide_header X-Powered-By;

    # Auth
    location / {
	auth_basic "Restricted Content";
	auth_basic_user_file /etc/nginx/.htpasswd;
	return 301 https://${domain}\$request_uri;
    }

    # 3X-UI
    location /${webBasePath}/ {
	proxy_pass https://127.0.0.1:${webPort}/${webBasePath}/;
    }
    location /${subPath}/ {
	proxy_pass https://127.0.0.1:${subPort}/${subPath}/;
    }
    location /${subJsonPath}/ {
	proxy_pass https://127.0.0.1:${subPort}/${subJsonPath}/;
    }
}
EOF

nginx -s reload
	echo ""
}


### SSH ####
ssh_setup() {
	echo -e "${blue}Настройка ssh${clear}"
	echo "Команда для Linux:"
	echo -e "${blue}ssh-copy-id -p 22 ${username}@${serverip}${clear}"
	echo "Команда для Windows:"
	echo -e "${blue}type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${username}@${serverip} \"cat >> ~/.ssh/authorized_keys\""
	echo ""
	echo -e "Закинули ключ SSH на сервер? (если нет, то потеряешь доступ к серверу) [y/N]${clear}"
	read answer
	if [[ $answer != "y" ]] && [[ $answer != "Y" ]]
	then
	        echo ""
	        echo -e $cancel
	        echo ""
	        exit
	fi
	
cat > /etc/ssh/sshd_config <<EOF
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/bin:/usr/bin:/bin:/usr/games

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

Port 22
#AddressFamily any
ListenAddress 127.0.0.1
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
KbdInteractiveAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin prohibit-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem       sftp    /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server
EOF

	systemctl restart ssh.service
	echo ""
}


### UFW ###
enabling_security() {
	echo -e "${blue}Настройка ufw${clear}"
	ufw allow 443/tcp
	ufw allow 80/tcp
	ufw allow 2091
	yes | ufw enable
	echo ""
}


### Окончание ###
data_output() {
	echo -e "${blue}Окончание настройки, доступ по ссылке:${clear}"
	echo -e "${green}https://${domain}/${webBasePath}/${clear}"
	echo ""
	echo -e "${blue}Логин: ${green}${username}${clear}"
 	echo -e "${blue}Пароль: ${green}${password}${clear}"
	echo ""
	echo -e "${blue}Подключение по ssh :${clear}"
	echo -e "${green}ssh -p 443 ${username}@www.${domain}${clear}"
	echo ""
	sleep 5
}

### Установка 3x-ui ###
panel_installation() {
	echo -e "${blue}Настройка 3x-ui xray${clear}"
	wget -q --show-progress https://github.com/cortez24rus/3X-UI-auto-deployment/raw/main/x-ui.db
	echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
	echo ""
	x-ui stop
	rm -rf /etc/x-ui/x-ui.db

	stream_settings_id6
	stream_settings_id7
	stream_settings_id8
 	database_change

	cp x-ui.db /etc/x-ui/
	sleep 1
	x-ui start
	echo ""
}

### Изменение базы данных ###
stream_settings_id6() {
stream_settings_id6=$(cat <<EOF
{
  "network": "kcp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 2091,
      "remark": ""
    }
  ],
  "kcpSettings": {
    "mtu": 1350,
    "tti": 20,
    "uplinkCapacity": 50,
    "downlinkCapacity": 100,
    "congestion": false,
    "readBufferSize": 1,
    "writeBufferSize": 1,
    "header": {
      "type": "srtp"
    },
    "seed": "x2aYTWwqUE"
  }
}
EOF
)
}

stream_settings_id7() {
stream_settings_id7=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "realitySettings": {
    "show": false,
    "xver": 0,
    "dest": "${reality}:443",
    "serverNames": [
      "${reality}",
      "www.${reality}"
    ],
    "privateKey": "0IQP3faZ4kB-boJg8QQhfAhEmCaveXn9M5Cpc2Ar_Xk",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "eee930481a21b35a",
      "82",
      "b58f324f09",
      "641f38df",
      "e933023c95c4db",
      "46e7226febe2",
      "3afc28",
      "9319"
    ],
    "settings": {
      "publicKey": "GKKuQzfRfJ0Q8IuPcobznJLjzrjagVz2R5krzJGktVg",
      "fingerprint": "chrome",
      "serverName": "",
      "spiderX": "/"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
)
}

stream_settings_id8() {
stream_settings_id8=$(cat <<EOF
{
  "network": "tcp",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "www.${domain}",
    "minVersion": "1.2",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
	"certificateFile": "/etc/letsencrypt/live/${domain}/fullchain.pem",
	"keyFile": "/etc/letsencrypt/live/${domain}/privkey.pem",
	"ocspStapling": 3600,
	"oneTimeLoading": false,
	"usage": "encipherment",
	"buildChain": false
      }
    ],
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "settings": {
      "allowInsecure": false,
      "fingerprint": "chrome"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
	)
}

database_change() {
DB_PATH="x-ui.db"

sqlite3 $DB_PATH <<EOF
UPDATE users SET username = '$username' WHERE id = 1;
UPDATE users SET password = '$password' WHERE id = 1;

UPDATE inbounds SET stream_settings = '$stream_settings_id6' WHERE id = 6;
UPDATE inbounds SET stream_settings = '$stream_settings_id7' WHERE id = 7;
UPDATE inbounds SET stream_settings = '$stream_settings_id8' WHERE id = 8;

UPDATE settings SET value = '${webPort}' WHERE id = 1;
SELECT value FROM settings WHERE id=1;
UPDATE settings SET value = '/${webBasePath}/' WHERE id = 2;
SELECT value FROM settings WHERE id=2;
UPDATE settings SET value = '${webCertFile}' WHERE id = 8;
SELECT value FROM settings WHERE id=8;
UPDATE settings SET value = '${webKeyFile}' WHERE id = 9;
SELECT value FROM settings WHERE id=9;
UPDATE settings SET value = '${subPort}' WHERE id = 28;
SELECT value FROM settings WHERE id=28;
UPDATE settings SET value = '/${subPath}/' WHERE id = 29;
SELECT value FROM settings WHERE id=29;
UPDATE settings SET value = '${webCertFile}' WHERE id = 31;
SELECT value FROM settings WHERE id=31;
UPDATE settings SET value = '${webKeyFile}' WHERE id = 32;
SELECT value FROM settings WHERE id=32;
UPDATE settings SET value = '${subURI}' WHERE id = 36;
SELECT value FROM settings WHERE id=36;
UPDATE settings SET value = '/${subJsonPath}/' WHERE id = 37;
SELECT value FROM settings WHERE id=37;
UPDATE settings SET value = '${subJsonURI}' WHERE id = 38;
SELECT value FROM settings WHERE id=38;
EOF
}


main_script() {
	check_root
	start_installation
	data_entry
	installation_of_utilities
	add_user
	uattended_upgrade
	dns_encryption
	enable_bbr
	disable_ipv6
	warp
	issuance_of_certificates
	nginx_setup
 	panel_installation
	ssh_setup
	enabling_security
	data_output
}

main_script
