#!/bin/bash

blue='\033[1;36m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
clear='\033[0m'

### INFO #################################################################################################
msg_ok() { echo -e "\e[1;42m $1 \e[0m";}	# green
msg_err() { echo -e "\e[1;41m $1 \e[0m";}	# red
msg_inf() { echo -e "\e[1;33m$1\e[0m";}		# yellow
msg_blue() { echo -e "\e[1;34m$1\e[0m";}	# blue

### Проверка ввода #######################################################################################
answer_input () {
	read answer
	if [[ $answer != "y" ]] && [[ $answer != "Y" ]]; then
		echo ""
		msg_err ОТМЕНА
		echo ""
		exit
	fi
	echo ""
}

validate_port() {
	local port_variable_name=$1
	while true; do
		read port_value
		# Проверка порта
		if [[ ! $port_value =~ ^[0-9]+$ ]] || (( $port_value < 1024 || $port_value > 65535)); then
			echo ""
			msg_err Ошибка: порт должен быть от 1024 до 65535
			msg_inf Пожалуйста, введите порт заново:
		else
			eval $port_variable_name=\$port_value
			break
		fi
	done
	echo ""
}

validate_path() {
	local path_variable_name=$1
	while true; do
		read path_value
		# Проверка на пустой ввод
		if [[ -z "$path_value" ]]; then
			echo ""
			msg_err Ошибка: путь не должен быть пустым
			msg_inf Пожалуйста, введите путь заново:
		# Проверка на наличие запрещённых символов
		elif [[ $path_value =~ ['{}\$/'] ]]; then
			echo ""
			msg_err Ошибка: путь не должен содержать символы /, $, {}, \
			msg_inf Пожалуйста, введите путь заново:
		else
			eval $path_variable_name=\$path_value
			break
		fi
	done
	echo ""
}

### IP сервера ###
check_ip() {
	serverip=$(curl -s ipinfo.io/ip)
}

### Проверка рута ###
check_root() {
	[[ $EUID -ne 0 ]] && echo "not root!" && sudo su -	
}

### Начало установки ###
start_installation() {
	clear
 	echo;msg_inf '           ___    _   _   _  '	;
	msg_inf		 ' \/ __ | |  | __ |_) |_) / \ '	;
	msg_inf		 ' /\    |_| _|_   |   | \ \_/ '	; echo
	
 	msg_err ВНИМАНИЕ!
	msg_inf Перед запуском скрипта рекомендуется выполнить следующие действия:
	echo -e "Обновить систему командой ${yellow}apt update && apt full-upgrade -y${clear}"
	echo -e "Перезагрузить сервер командой ${yellow}reboot${clear}"
	echo ""
	msg_inf Скрипт установки 3x-ui. Начать установку? Выберите опцию [y/N]
	answer_input
}

### Ввод данных ###
data_entry() {
	msg_inf Введите имя пользователя:
	read -r username
	echo ""
	msg_inf Введите пароль пользователя:
	read password
	echo ""
	
	echo -e "${blue}Введите доменное имя, под которое будете маскироваться (Reality):${clear}"
	read reality
	echo ""

 	echo -e "${blue}Введите 2 доменное имя, под которое будете маскироваться (Reality):${clear}"
	read reality2
	echo ""

	echo -e "${blue}Введите путь к Cloudflare grpc:${clear}"
	read cdngrpc
	echo ""

	echo -e "${blue}Введите путь к Cloudflare websocket:${clear}"
	read cdnws
	echo ""

	echo -e "${blue}Укажите свой домен:${clear}"
	read domain
	if [[ "$domain" == "www."* ]]; then
		domain=${domain#"www."}
	fi
	echo ""
	
	echo -e "${blue}Введите 1 для установки adguard-home (DoH)${clear}"
	echo -e "${blue}Введите 2 для установки systemd-resolved (DoT)${clear}"
	while true; do
	    read choise
	    echo ""
	    case $choise in
	        1)
	            echo -e "${blue}Введите путь до adguard-home (без символов '/', '$', '{}', '\'):${clear}"
	            validate_path adguardPath
	            break
	            ;;
	        2)
	            echo -e "${green}Выбран systemd-resolved${clear}"
	            echo ""
	            break
	            ;;
	        *)
	            echo -e "${red}Неверный выбор, попробуйте снова${clear}"
	            ;;
	    esac
	done
	
	echo -e "${blue}Введите порт панели:${clear}"
	validate_port webPort

	echo -e "${blue}Введите путь к панели (без символов '/', '$', '{}', '\'):${clear}"
	validate_path webBasePath

	echo -e "${blue}Введите порт подписки:${clear}"
	validate_port subPort

 	echo -e "${blue}Введите путь к подписке (без символов '/', '$', '{}', '\'):${clear}"
	validate_path subPath

	echo -e "${blue}Введите путь к JSON подписке (без символов '/', '$', '{}', '\'):${clear}"
	validate_path subJsonPath
	
	echo -e "${blue}Введите вашу почту, зарегистрированную на Cloudflare:${clear}"
	read email
	echo ""

	echo -e "${blue}Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:${clear}"
	read cftoken
	echo ""

	echo -e "${blue}Введите ключ для регистрации WARP или нажмите Enter для пропуска:${clear}"
	read warpkey
	echo ""
	
	webCertFile=/etc/letsencrypt/live/${domain}/fullchain.pem
	webKeyFile=/etc/letsencrypt/live/${domain}/privkey.pem
	subURI=https://${domain}/${subPath}/
	subJsonURI=https://${domain}/${subJsonPath}/
}

### Обновление системы и установка пакетов ###
installation_of_utilities() {
	echo -e "${blue}Обновление системы и установка необходимых пакетов${clear}"
	apt-get update && apt-get upgrade -y
	apt-get install -y gnupg2
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list	
	apt-get update && apt-get upgrade -y
	apt-get install -y git wget sudo nginx-full net-tools apache2-utils gnupg2 sqlite3 curl ufw certbot python3-certbot-dns-cloudflare unattended-upgrades cloudflare-warp systemd-resolved
 	echo -e "${green}Все пакеты установлены${clear}"
	echo ""
}

### DoH, DoT ###
dns_encryption() {
	case $choise in
		1)
			dns_adguard_home
			comment_agh="location /${adguardPath}/ {
		proxy_redirect /login.html /${adguardPath}/login.html;
		proxy_pass http://127.0.0.1:8080/;
	}"
			;;
		2)
			dns_systemd_resolved
			comment_agh=""
			;;
		*)
			echo -e "${red}Неверный выбор, попробуйте снова${clear}"
			dns_encryption
			;;
	esac
}

dns_systemd_resolved_for_adguard() {
cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
# Some examples of DNS servers which may be used for DNS= and FallbackDNS=:
# Cloudflare: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
# Google:     8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
# Quad9:      9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net
DNS=127.0.0.1
#FallbackDNS=
#Domains=
#DNSSEC=no
DNSOverTLS=no
DNSStubListener=no
EOF

	systemctl restart systemd-resolved.service
}

# systemd-resolved
dns_systemd_resolved() {
	echo -e "${blue}Настройка systemd-resolved${clear}"

cat > /etc/systemd/resolved.conf <<EOF
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

dns_adguard_home() {
	dns_systemd_resolved
	echo -e "${blue}Настройка adguard-home${clear}"
	wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz
	tar xvf AdGuardHome_linux_amd64.tar.gz
	AdGuardHome/AdGuardHome -s install
	hash=$(htpasswd -B -C 10 -n -b ${username} ${password} | cut -d ":" -f 2)

cat > AdGuardHome/AdGuardHome.yaml <<EOF
http:
  pprof:
    port: 6060
    enabled: false
  address: 127.0.0.1:8080
  session_ttl: 720h
users:
  - name: ${username}
    password: ${hash}
auth_attempts: 5
block_auth_min: 15
http_proxy: ""
language: ""
theme: auto
dns:
  bind_hosts:
    - 0.0.0.0
  port: 53
  anonymize_client_ip: false
  ratelimit: 20
  ratelimit_subnet_len_ipv4: 24
  ratelimit_subnet_len_ipv6: 56
  ratelimit_whitelist: []
  refuse_any: true
  upstream_dns:
    - https://dns.cloudflare.com/dns-query
    - https://dns.google/dns-query
    - https://dns10.quad9.net/dns-query
    - tls://one.one.one.one
    - tls://dns.google
    - tls://dns10.quad9.net
  upstream_dns_file: ""
  bootstrap_dns:
    - 9.9.9.10
    - 149.112.112.10
    - 2620:fe::10
    - 2620:fe::fe:10
  fallback_dns: []
  upstream_mode: parallel
  fastest_timeout: 1s
  allowed_clients: []
  disallowed_clients: []
  blocked_hosts:
    - version.bind
    - id.server
    - hostname.bind
  trusted_proxies:
    - 127.0.0.0/8
    - ::1/128
  cache_size: 4194304
  cache_ttl_min: 0
  cache_ttl_max: 0
  cache_optimistic: false
  bogus_nxdomain: []
  aaaa_disabled: false
  enable_dnssec: false
  edns_client_subnet:
    custom_ip: ""
    enabled: false
    use_custom: false
  max_goroutines: 300
  handle_ddr: true
  ipset: []
  ipset_file: ""
  bootstrap_prefer_ipv6: false
  upstream_timeout: 10s
  private_networks: []
  use_private_ptr_resolvers: true
  local_ptr_upstreams: []
  use_dns64: false
  dns64_prefixes: []
  serve_http3: false
  use_http3_upstreams: false
  serve_plain_dns: true
  hostsfile_enabled: true
tls:
  enabled: false
  server_name: ""
  force_https: false
  port_https: 443
  port_dns_over_tls: 853
  port_dns_over_quic: 853
  port_dnscrypt: 0
  dnscrypt_config_file: ""
  allow_unencrypted_doh: false
  certificate_chain: ""
  private_key: ""
  certificate_path: ""
  private_key_path: ""
  strict_sni_check: false
querylog:
  dir_path: ""
  ignored: []
  interval: 2160h
  size_memory: 1000
  enabled: true
  file_enabled: true
statistics:
  dir_path: ""
  ignored: []
  interval: 24h
  enabled: true
filters:
  - enabled: true
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt
    name: AdGuard DNS filter
    id: 1
  - enabled: false
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt
    name: AdAway Default Blocklist
    id: 2
  - enabled: true
    url: https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt
    name: Steven Black's List
    id: 1725212203
whitelist_filters: []
user_rules: []
dhcp:
  enabled: false
  interface_name: ""
  local_domain_name: lan
  dhcpv4:
    gateway_ip: ""
    subnet_mask: ""
    range_start: ""
    range_end: ""
    lease_duration: 86400
    icmp_timeout_msec: 1000
    options: []
  dhcpv6:
    range_start: ""
    lease_duration: 86400
    ra_slaac_only: false
    ra_allow_slaac: false
filtering:
  blocking_ipv4: ""
  blocking_ipv6: ""
  blocked_services:
    schedule:
      time_zone: Local
    ids: []
  protection_disabled_until: null
  safe_search:
    enabled: false
    bing: true
    duckduckgo: true
    google: true
    pixabay: true
    yandex: true
    youtube: true
  blocking_mode: default
  parental_block_host: family-block.dns.adguard.com
  safebrowsing_block_host: standard-block.dns.adguard.com
  rewrites: []
  safebrowsing_cache_size: 1048576
  safesearch_cache_size: 1048576
  parental_cache_size: 1048576
  cache_time: 30
  filters_update_interval: 24
  blocked_response_ttl: 10
  filtering_enabled: true
  parental_enabled: false
  safebrowsing_enabled: false
  protection_enabled: true
clients:
  runtime_sources:
    whois: true
    arp: true
    rdns: true
    dhcp: true
    hosts: true
  persistent: []
log:
  enabled: true
  file: ""
  max_backups: 0
  max_size: 100
  max_age: 3
  compress: false
  local_time: false
  verbose: false
os:
  group: ""
  user: ""
  rlimit_nofile: 0
schema_version: 28
EOF

	dns_systemd_resolved_for_adguard
	AdGuardHome/AdGuardHome -s restart
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
    if [[ -n "$key" ]];
	then
		warp-cli registration license ${warpkey}
	fi
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
	touch /etc/nginx/.htpasswd

	nginx_conf
	stream_conf
	local_conf

	nginx -s reload
	echo ""
}

nginx_conf() {
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
}

stream_conf() {
cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_protocol \$backend {
	default           \$https;
	""                ssh;
}
map \$ssl_preread_server_name \$https {
	cg.${domain}	cg;
	cw.${domain}    cw;
	${reality}                 reality;
	${reality2}            reality2;
	www.${domain}     trojan;
	${domain}         web;
}
upstream cg             { server 127.0.0.1:2053; }
upstream cw             { server 127.0.0.1:2083; }
upstream reality        { server 127.0.0.1:7443; }
upstream reality2       { server 127.0.0.1:8443; }
upstream trojan         { server 127.0.0.1:9443; }
upstream web            { server 127.0.0.1:46076; }
upstream ssh            { server 127.0.0.1:22; }

server {
	listen 443          reuseport;
	ssl_preread         on;
	proxy_pass          \$backend;
}
EOF
}

local_conf() {
cat > /etc/nginx/conf.d/local.conf <<EOF
# HTTP redirect
server {
	listen 80 default_server;
	server_name _;

	# Disable direct IP access
	if (\$host = ${serverip}) {
		return 444;
	}

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

	# Disable direct IP access
	if (\$host = ${serverip}) {
		return 444;
	}

	# Auth
	location / {
		auth_basic "Restricted Content";
		auth_basic_user_file /etc/nginx/.htpasswd;
	}

	# 3X-UI
	location /${webBasePath} {
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_set_header Host \$http_host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header Range \$http_range;
		proxy_set_header If-Range \$http_if_range;
		proxy_redirect off;
		proxy_pass https://127.0.0.1:${webPort}/${webBasePath};
	}
	location /${subPath} {
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_set_header Host \$http_host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header Range \$http_range;
		proxy_set_header If-Range \$http_if_range;
		proxy_redirect off;
		proxy_pass https://127.0.0.1:${subPort}/${subPath};
	}
	location /${subJsonPath} {
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto \$scheme;
		proxy_set_header Host \$http_host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header Range \$http_range;
		proxy_set_header If-Range \$http_if_range;
		proxy_redirect off;
		proxy_pass https://127.0.0.1:${subPort}/${subJsonPath};
	}
	# Adguard home
	${comment_agh}
}
EOF
}

### Установка 3x-ui ###
panel_installation() {
	touch /usr/local/bin/reinstallation_check
	echo -e "${blue}Настройка 3x-ui xray${clear}"
	wget -q --show-progress https://github.com/cortez24rus/3X-UI-auto-deployment/raw/main/x-ui.db.gpg
	gpg --batch --yes --passphrase ${password} x-ui.db.gpg

 	echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

	stream_settings_id1
	stream_settings_id2
	stream_settings_id3
	stream_settings_id4
	stream_settings_id5
	stream_settings_id6
	database_change
	
	x-ui stop
	sleep 1
	rm -rf /etc/x-ui/x-ui.db
	sleep 1
	mv x-ui.db /etc/x-ui/
	sleep 1
	x-ui start
	echo ""
}

### Изменение базы данных ###
stream_settings_id1() {
stream_settings_id1=$(cat <<EOF
{
  "network": "grpc",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "cg.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "cg.${domain}",
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
    "alpn": [],
    "settings": {
      "allowInsecure": false,
      "fingerprint": "random"
    }
  },
  "grpcSettings": {
	"serviceName": "${cdngrpc}",
    "authority": "",
    "multiMode": false
  }
}
EOF
)
}

stream_settings_id2() {
stream_settings_id2=$(cat <<EOF
{
  "network": "ws",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "cw.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "cw.${domain}",
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
    "alpn": [],
    "settings": {
      "allowInsecure": false,
      "fingerprint": "randomized"
    }
  },
  "wsSettings": {
    "acceptProxyProtocol": false,
    "path": "/${cdnws}",
    "host": "",
    "headers": {}
  }
}
EOF
)
}

stream_settings_id3() {
stream_settings_id3=$(cat <<EOF
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
      "${reality}"
    ],
    "privateKey": "GHs4uwykI3IJWSdLLfKyuJjUV6J5zf29sAFXWNjePxA",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "45eeb98c"
    ],
    "settings": {
      "publicKey": "Tvi8JCN0ESRBUr3PT3hB9Xh3Gr7SRcm6mZBYNN4DD3A",
      "fingerprint": "randomized",
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

stream_settings_id4() {
stream_settings_id4=$(cat <<EOF
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
    "dest": "${reality2}:443",
    "serverNames": [
      "${reality2}"
    ],
    "privateKey": "iP8Xy-bot_mKf75yI9DC0nkQjR-qaolU4evrKAud3XE",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "b54428af"
    ],
    "settings": {
      "publicKey": "RPQbnAtvBwa6IrnvYvsEU0WVaRWhRembfHMpbVjZ9lU",
      "fingerprint": "randomized",
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

stream_settings_id5() {
stream_settings_id5=$(cat <<EOF
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

stream_settings_id6() {
stream_settings_id6=$(cat <<EOF
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
      "fingerprint": "randomized"
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

UPDATE inbounds SET stream_settings = '$stream_settings_id1' WHERE id = 1;
UPDATE inbounds SET stream_settings = '$stream_settings_id2' WHERE id = 2;
UPDATE inbounds SET stream_settings = '$stream_settings_id3' WHERE id = 3;
UPDATE inbounds SET stream_settings = '$stream_settings_id4' WHERE id = 4;
UPDATE inbounds SET stream_settings = '$stream_settings_id5' WHERE id = 5;
UPDATE inbounds SET stream_settings = '$stream_settings_id6' WHERE id = 6;

UPDATE settings SET value = '${webPort}' WHERE id = 1;
UPDATE settings SET value = '/${webBasePath}/' WHERE id = 2;
UPDATE settings SET value = '${webCertFile}' WHERE id = 8;
UPDATE settings SET value = '${webKeyFile}' WHERE id = 9;
UPDATE settings SET value = '${subPort}' WHERE id = 28;
UPDATE settings SET value = '/${subPath}/' WHERE id = 29;
UPDATE settings SET value = '${webCertFile}' WHERE id = 31;
UPDATE settings SET value = '${webKeyFile}' WHERE id = 32;
UPDATE settings SET value = '${subURI}' WHERE id = 36;
UPDATE settings SET value = '/${subJsonPath}/' WHERE id = 37;
UPDATE settings SET value = '${subJsonURI}' WHERE id = 38;
EOF
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
	answer_input

	sed -i -e "s/#Port/Port/g" /etc/ssh/sshd_config
	sed -i -e "s/#ListenAddress 0.0.0.0/ListenAddress 127.0.0.1/g" /etc/ssh/sshd_config
	sed -i -e "s/#PermitRootLogin/PermitRootLogin/g" -e "s/PermitRootLogin yes/PermitRootLogin prohibit-password/g" /etc/ssh/sshd_config
	sed -i -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" -e "s/PubkeyAuthentication no/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
	sed -i -e "s/#PasswordAuthentication/PasswordAuthentication/g" -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
	sed -i -e "s/#PermitEmptyPasswords/PermitEmptyPasswords/g" -e "s/PermitEmptyPasswords yes/PermitEmptyPasswords no/g" /etc/ssh/sshd_config

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
	echo -e "${blue}Доступ по ссылке к 3x-ui панели:${clear}"
	echo -e "${green}https://${domain}/${webBasePath}/${clear}"
	echo ""
	if [[ $choise = "1" ]]; then
		echo -e "${blue}Доступ по ссылке к adguard-home (если вы его выбирали):${clear}"
		echo -e "${green}https://${domain}/${adguardPath}/login.html${clear}"
		echo ""
	fi
	echo -e "${blue}Подключение по ssh :${clear}"
	echo -e "${green}ssh -p 443 ${username}@www.${domain}${clear}"
	echo ""
	echo -e "${blue}Логин: ${green}${username}${clear}"
 	echo -e "${blue}Пароль: ${green}${password}${clear}"
	echo ""
	
	sleep 3
}


### Первый запуск ###
main_script_first() {
  check_ip
  check_root
  start_installation
  data_entry
  installation_of_utilities
  dns_encryption
  add_user
  uattended_upgrade
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

### Повторный запуск ###
main_script_repeat() {
  check_ip
  check_root
  start_installation
  data_entry
  dns_encryption
  nginx_setup
  panel_installation
  data_output
}

main_choise() {
  if [ -f /usr/local/bin/reinstallation_check ]; then
    echo ""
    echo -e "${red}Повторная установка скрипта${clear}"
    sleep 2
    main_script_repeat
    echo ""
    exit 1
  else
    main_script_first
  fi
}

main_choise
