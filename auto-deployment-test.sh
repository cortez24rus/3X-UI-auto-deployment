#!/bin/bash

LOGFILE="/var/log/3X-UI-auto-deployment.log"

### INFO ###
Green="\033[32m"
Red="\033[31m"
Yellow="\e[1;33m"
Blue="\033[36m"
Orange="\033[38;5;214m"
Font="\e[0m"


OK="${Green}[OK]${Font}"
ERROR="${Red}[!]${Font}"
QUESTION="${Green}[?]${Font}"

function msg_banner()	{ echo -e "${Yellow} $1 ${Font}"; }
function msg_ok()	{ echo -e "${OK} ${Blue} $1 ${Font}"; }
function msg_err()	{ echo -e "${ERROR} ${Orange} $1 ${Font}"; }
function msg_inf()	{ echo -e "${QUESTION} ${Yellow} $1 ${Font}"; }
function msg_out()	{ echo -e "${Green} $1 ${Font}"; }
function msg_tilda()	{ echo -e "${Orange}$1${Font}"; }

exec > >(tee -a "$LOGFILE") 2>&1

### Продолжение? ###
answer_input() {
    read -r answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
	echo
	msg_err "ОТМЕНА"
	echo
        return 1  # Возвращаем 1, если ответ не 'y' или 'Y'
    fi
    return 0  # Возвращаем 0, если ответ 'y' или 'Y'
}

validate_path() {
	local path_variable_name=$1
	while true; do
		read path_value
		# Проверка на пустой ввод
		if [[ -z "$path_value" ]]; then
			msg_err "Ошибка: путь не должен быть пустым"
			echo
			msg_inf "Пожалуйста, введите путь заново:"
		# Проверка на наличие запрещённых символов
		elif [[ $path_value =~ ['{}\$/'] ]]; then
			msg_err "Ошибка: путь не должен содержать символы (/, $, {}, \)"
			echo
			msg_inf "Пожалуйста, введите путь заново:"
		else
			eval $path_variable_name=\$path_value
			break
		fi
	done
}

# Функция для генерации случайного порта
generate_port() {
	echo $(( ((RANDOM<<15)|RANDOM) % 49152 + 10000 ))
}
# Функция для проверки, занят ли порт
is_port_free() {
	local port=$1
	nc -z 127.0.0.1 $port &>/dev/null
	return $?
}
# Основной цикл для генерации и проверки порта
port_issuance() {
	while true; do
		PORT=$(generate_port)
		if ! is_port_free $PORT; then  # Если порт свободен, выходим из цикла
			echo $PORT
			break
		fi
	done
}

choise_dns () {
	while true; do
		read choise
		case $choise in
			1)
				echo
				msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
				echo
				msg_inf "Введите путь к adguard-home (без символов /, $, {}, \):"
				validate_path adguardPath
				break
				;;
			2)
				msg_ok "Выбран systemd-resolved"
				break
				;;
			*)	
				msk_err "Неверный выбор, попробуйте снова"
				;;
		esac
	done
}

crop_domain() {
    domain=${domain//https:\/\//}
    domain=${domain//http:\/\//}
    domain=${domain//www./}
    domain=${domain%%/*}

    if ! [[ "$domain" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$ ]]; then
        msg_err "Ошибка: введённый домен '$domain' имеет неверный формат."
        return 1
    fi
    return 0
}

get_test_response() {
    testdomain=$(echo "${domain}" | rev | cut -d '.' -f 1-2 | rev)

    if [[ "$cftoken" =~ [A-Z] ]]; then
        test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "Authorization: Bearer ${cftoken}" --header "Content-Type: application/json")
    else
        test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "X-Auth-Key: ${cftoken}" --header "X-Auth-Email: ${email}" --header "Content-Type: application/json")
    fi
}

validate_input() {
    get_test_response
    
    if [[ -n $(echo "$test_response" | grep "\"${testdomain}\"") ]] && \
       [[ -n $(echo "$test_response" | grep "\"#dns_records:edit\"") ]] && \
       [[ -n $(echo "$test_response" | grep "\"#dns_records:read\"") ]] && \
       [[ -n $(echo "$test_response" | grep "\"#zone:read\"") ]]; then
        return 0
    else
        return 1
    fi
}

check_cf_token() {
    while true; do
        while [[ -z $domain ]]; do
            echo
            msg_inf "Введите ваш домен:"
            read domain
            echo
        done

        crop_domain
        
	if [[ $? -ne 0 ]]; then
            domain=""
            continue
        fi

        while [[ -z $email ]]; do
            msg_inf "Введите вашу почту, зарегистрированную на Cloudflare:"
            read email
            echo
        done

        while [[ -z $cftoken ]]; do
            msg_inf "Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:"
            read cftoken
            echo
        done

        msg_err "Проверка домена, API токена/ключа и почты..."

        if validate_input; then
            break
        else
            msg_err "Ошибка: неправильно введён домен, API токен/ключ или почта. Попробуйте снова."
            domain=""
            email=""
            cftoken=""
        fi
    done
}

### IP сервера ###
check_ip() {
	IP4_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
	IP4=$(ip route get 8.8.8.8 2>&1 | grep -Po -- 'src \K\S*')
	[[ $IP4 =~ $IP4_REGEX ]] || IP4=$(curl -s ipinfo.io/ip);
}

### Проверка рута ###
check_root() {
	[[ $EUID -ne 0 ]] && echo "not root!" && sudo su -
}

### Баннер ###
banner_1() {
	echo
	msg_banner " ╻ ╻┏━┓┏━┓╻ ╻   ┏━┓┏━╸╻ ╻┏━╸┏━┓┏━┓┏━╸   ┏━┓┏━┓┏━┓╻ ╻╻ ╻ "
	msg_banner " ┏╋┛┣┳┛┣━┫┗┳┛   ┣┳┛┣╸ ┃┏┛┣╸ ┣┳┛┗━┓┣╸    ┣━┛┣┳┛┃ ┃┏╋┛┗┳┛ "
	msg_banner " ╹ ╹╹┗╸╹ ╹ ╹    ╹┗╸┗━╸┗┛ ┗━╸╹┗╸┗━┛┗━╸   ╹  ╹┗╸┗━┛╹ ╹ ╹  "
	echo
	echo
}

### Начало установки ###
start_installation() {
 	msg_err "ВНИМАНИЕ!"
	echo
	msg_err "Перед запуском скрипта рекомендуется выполнить следующие действия:"
	msg_ok "apt update && apt full-upgrade -y && reboot"
	echo
	msg_inf "Начать установку XRAY? Выберите опцию [y/N]"
	answer_input
}

### Ввод данных ###
data_entry() {
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите имя пользователя:"
	read username
	msg_inf "Введите пароль пользователя:"
	read password
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите доменное имя, под которое будете маскироваться Reality:"
	read reality
	msg_inf "Введите 2 доменное имя, под которое будете маскироваться Reality:"
	read reality2
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите путь к Cloudflare grpc:"
	validate_path cdngrpc
	msg_inf "Введите путь к Cloudflare websocket:"
	validate_path cdnws
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf	"Введите 1, для установки adguard-home (DoH-DoT)"
	msg_inf	"Введите 2, для установки systemd-resolved (DoT)"
	choise_dns
	msg_inf "Введите путь к панели (без символов /, $, {}, \):"
	validate_path webBasePath
	msg_inf "Введите путь к подписке (без символов /, $, {}, \):"
	validate_path subPath
	msg_inf "Введите путь к JSON подписке (без символов /, $, {}, \):"
	validate_path subJsonPath
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
 	check_cf_token
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	msg_inf "Введите ключ для регистрации WARP или нажмите Enter для пропуска:"
	read warpkey
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	webPort=$(port_issuance)
	subPort=$(port_issuance)

	webCertFile=/etc/letsencrypt/live/${domain}/fullchain.pem
	webKeyFile=/etc/letsencrypt/live/${domain}/privkey.pem
	subURI=https://${domain}/${subPath}/
	subJsonURI=https://${domain}/${subJsonPath}/
}

### Обновление системы и установка пакетов ###
installation_of_utilities() {
	msg_inf "Обновление системы и установка необходимых пакетов"
	apt-get update && apt-get upgrade -y
	apt-get install -y gnupg2
	curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list	
	apt-get update && apt-get upgrade -y
	apt-get install -y git wget sudo nginx-full net-tools apache2-utils gnupg2 sqlite3 curl ufw certbot python3-certbot-dns-cloudflare unattended-upgrades cloudflare-warp systemd-resolved
	echo
 	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### DoH, DoT ###
dns_encryption() {
	msg_inf "Настройка dns"
	dns_systemd_resolved
	case $choise in
		1)
			comment_agh="location /${adguardPath}/ {
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header Range \$http_range;
		proxy_set_header If-Range \$http_if_range;
		proxy_redirect /login.html /${adguardPath}/login.html;
		proxy_pass http://127.0.0.1:8081/;
		break;
	}"
			dns_adguard_home
			dns_systemd_resolved_for_adguard
			echo
			msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
			echo
			;;
		2)
			comment_agh=""
   			echo
			msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
			echo
			;;
		*)
			msg_err "Неверный выбор, попробуйте снова"
			dns_encryption
			;;
	esac
}

# systemd-resolved
dns_systemd_resolved() {
	cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
# Some examples of DNS servers which may be used for DNS= and FallbackDNS=:
# Cloudflare: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
# Google:     8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
# Quad9:      9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net
DNS=1.1.1.1
#FallbackDNS=
Domains=~.
DNSSEC=yes
DNSOverTLS=yes
EOF
	systemctl restart systemd-resolved.service
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

dns_adguard_home() {
	rm -rf AdGuardHome_*
	while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz; do
    	msg_err "Скачивание не удалось, пробуем снова..."
    	sleep 3
	done
	tar xvf AdGuardHome_linux_amd64.tar.gz
	AdGuardHome/AdGuardHome -s install
	hash=$(htpasswd -B -C 10 -n -b ${username} ${password} | cut -d ":" -f 2)
	cat > AdGuardHome/AdGuardHome.yaml <<EOF
http:
  pprof:
    port: 6060
    enabled: false
  address: 127.0.0.1:8081
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
	AdGuardHome/AdGuardHome -s restart
}

### Добавление пользователя ###
add_user() {
 	msg_inf "Добавление пользователя"
	useradd -m -s $(which bash) -G sudo ${username}
	echo "${username}:${password}" | chpasswd
	mkdir -p /home/${username}/.ssh/
	touch /home/${username}/.ssh/authorized_keys
	chown ${username}: /home/${username}/.ssh
	chmod 700 /home/${username}/.ssh
	chown ${username}:${username} /home/${username}/.ssh/authorized_keys
	echo ${username}
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### Безопасность ###
uattended_upgrade() {
	msg_inf "Автоматическое обновление безопасности"
	echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
	echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
	dpkg-reconfigure -f noninteractive unattended-upgrades
	systemctl restart unattended-upgrades
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### BBR ###
enable_bbr() {
	msg_inf "Включение BBR"
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
	msg_inf "Отключение IPv6"
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
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### WARP ###
warp() {
	msg_inf "Настройка warp"
	yes | warp-cli registration new
	warp-cli mode proxy
	warp-cli connect
    	if [[ -n "$warpkey" ]];
	then
		warp-cli registration license ${warpkey}
	fi
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### СЕРТИФИКАТЫ ###
issuance_of_certificates() {
	msg_inf "Выдача сертификатов"
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
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### NGINX ###
nginx_setup() {
	msg_inf "Настройка NGINX"
	mkdir -p /etc/nginx/stream-enabled/
	touch /etc/nginx/.htpasswd

	nginx_conf
	stream_conf
	local_conf

	nginx -s reload
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
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
map \$ssl_preread_server_name \$backend {
	${reality}                reality;
	${reality2}         reality2;
	www.${domain}  trojan;
	${domain}      web;
}
upstream reality         { server 127.0.0.1:7443; }
upstream reality2        { server 127.0.0.1:8443; }
upstream trojan          { server 127.0.0.1:9443; }
upstream web             { server 127.0.0.1:46076; }
upstream ssh             { server 127.0.0.1:22; }

server {
	listen 443           reuseport;
	ssl_preread          on;
	proxy_pass           \$backend;
}
EOF
}

local_conf() {
	cat > /etc/nginx/conf.d/local.conf <<EOF
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
	ssl_certificate             ${webCertFile};
	ssl_certificate_key         ${webKeyFile};
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

	# Security
	if (\$host !~* ^(.+\.)?${domain}\$ ){return 444;}
	if (\$scheme ~* https) {set \$safe 1;}
	if (\$ssl_server_name !~* ^(.+\.)?${domain}\$ ) {set \$safe "\${safe}0"; }
	if (\$safe = 10){return 444;}
	if (\$request_uri ~ "(\"|'|\`|~|,|:|--|;|%|\\$|&&|\?\?|0x00|0X00|\||\\|\{|\}|\[|\]|<|>|\.\.\.|\.\.\/|\/\/\/)"){set \$hack 1;}
	error_page 400 401 402 403 500 501 502 503 504 =404 /404;
	proxy_intercept_errors on;

	# Disable direct IP access
	if (\$host = ${IP4}) {
		return 444;
	}

	# Auth
	location / {
		auth_basic "Restricted Content";
		auth_basic_user_file /etc/nginx/.htpasswd;
	}
	# X-ui Admin panel
	location /${webBasePath} {
		proxy_redirect off;
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header Range \$http_range;
		proxy_set_header If-Range \$http_if_range;
		proxy_pass https://127.0.0.1:${webPort}/${webBasePath};
		break;
	}
	# Subscription 
	location /${subPath} {
		if (\$hack = 1) {return 404;}
		proxy_redirect off;
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_pass https://127.0.0.1:${subPort}/${subPath};
		break;
	}
	# Subscription json
	location /${subJsonPath} {
		if (\$hack = 1) {return 404;}
		proxy_redirect off;
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_pass https://127.0.0.1:${subPort}/${subJsonPath};
		break;
	}
	# Xray Config
	location ~ ^/(?<fwdport>\d+)/(?<fwdpath>.*)\$ {
		if (\$hack = 1) {return 404;}
		client_max_body_size 0;
		client_body_timeout 1d;
		grpc_read_timeout 1d;
		grpc_socket_keepalive on;
		proxy_read_timeout 1d;
		proxy_http_version 1.1;
		proxy_buffering off;
		proxy_request_buffering off;
		proxy_socket_keepalive on;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		if (\$content_type ~* "GRPC") {
			grpc_pass grpc://127.0.0.1:\$fwdport\$is_args\$args;
			break;
		}
		if (\$http_upgrade ~* "(WEBSOCKET|WS)") {
			proxy_pass https://127.0.0.1:\$fwdport\$is_args\$args;
			break;
	        }
		if (\$request_method ~* ^(PUT|POST|GET)\$) {
			proxy_pass http://127.0.0.1:\$fwdport\$is_args\$args;
			break;
		}
	}
	# Adguard home
	${comment_agh}
}
EOF
}

### Установка 3x-ui ###
panel_installation() {
	touch /usr/local/bin/reinstallation_check
	msg_inf "Настройка 3x-ui xray"
	while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused https://github.com/cortez24rus/3X-UI-auto-deployment/raw/main/x-ui.gpg; do
    	msg_err "Скачивание не удалось, пробуем снова..."
    	sleep 3
	done
	echo ${password} | gpg --batch --yes --passphrase-fd 0 -d x-ui.gpg > x-ui.db
	echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) > /dev/null 2>&1

	stream_settings_id1
	stream_settings_id2
	stream_settings_id3
	stream_settings_id4
	stream_settings_id5
	stream_settings_id6
	database_change

	x-ui stop
	rm -rf x-ui.gpg
	rm -rf /etc/x-ui/x-ui.db
	mv x-ui.db /etc/x-ui/
	x-ui start
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### Изменение базы данных ###
stream_settings_id1() {
	stream_settings_id1=$(cat <<EOF
{
  "network": "grpc",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "grpcSettings": {
    "serviceName": "/2053/${cdngrpc}",
    "authority": "${domain}",
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
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "${domain}",
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
  "wsSettings": {
    "acceptProxyProtocol": false,
    "path": "/2083/${cdnws}",
    "host": "${domain}",
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

### UFW ###
enabling_security() {
	msg_inf "Настройка ufw"
	ufw --force reset
	ufw limit 36079/tcp
	ufw allow 443/tcp
 	ufw limit 22/tcp
	ufw insert 1 deny from $(echo ${IP4} | cut -d '.' -f 1-3).0/22
	ufw --force enable
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### SSH ####
ssh_setup() {
	msg_inf "Настройка ssh"
 	msg_inf "Сгенерируйте ключ для своей ОС (ssh-keygen)"
	echo	
 	msg_inf "В windows нужно установить пакет openSSH, и ввести команду в POWERSHELL (предлагаю изучить как генерировать ключ в интернете)"
	msg_inf "Если у вас linux, то вы сами все умеете С:"
 	echo
  	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
	echo -n "Команда для Windows: " && msg_out "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${username}@${IP4} \"cat >> ~/.ssh/authorized_keys\""	
  	echo -n "Команда для Linux: " && msg_out "ssh-copy-id -p 22 ${username}@${IP4}"
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
 	echo
	msg_inf "Настроить ssh (шаг не обязательный)? [y/N]"
	answer_input

	if [[ $? -eq 0 ]]; then
	    sed -i -e "s/#Port/Port/g" /etc/ssh/sshd_config
	    sed -i -e "s/Port 22/Port 36079/g" /etc/ssh/sshd_config
	    sed -i -e "s/#PermitRootLogin/PermitRootLogin/g" -e "s/PermitRootLogin yes/PermitRootLogin prohibit-password/g" /etc/ssh/sshd_config
	    sed -i -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" -e "s/PubkeyAuthentication no/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
	    sed -i -e "s/#PasswordAuthentication/PasswordAuthentication/g" -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
	    sed -i -e "s/#PermitEmptyPasswords/PermitEmptyPasswords/g" -e "s/PermitEmptyPasswords yes/PermitEmptyPasswords no/g" /etc/ssh/sshd_config
	
	    systemctl restart ssh.service
	    echo "Настройка SSH завершена."
	fi
 	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

### Окончание ###
data_output() {
	exec > /dev/tty 2>&1
	echo
	msg_err "PLEASE SAVE THIS SCREEN!"
	printf '0\n' | x-ui | grep --color=never -i ':'
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo -n "Доступ по ссылке к 3x-ui панели: " && msg_out "https://${domain}/${webBasePath}/"
	if [[ $choise = "1" ]]; then
		echo -n "Доступ по ссылке к adguard-home: " && msg_out "https://${domain}/${adguardPath}/login.html"
	fi
 	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo -n "Подключение по ssh: " && msg_out "		 ssh -p 36079 ${username}@${IP4}"
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" 	
 	echo -n "Username: " && msg_out "			 ${username}"
	echo -n "Password: " && msg_out "			 ${password}"
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
 	echo -n "Путь к лог файлу: " && msg_out "		 $LOGFILE"
	echo
	msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo
}

# Удаление всех управляющих последовательностей
log_clear() {
    sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$LOGFILE"
}


### Первый запуск ###
main_script_first() {
	check_ip
	check_root
	banner_1
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
	enabling_security
	ssh_setup
	data_output
	banner_1
	log_clear
}

### Повторный запуск ###
main_script_repeat() {
	check_ip
	check_root
	banner_1
	start_installation
	data_entry
	dns_encryption
	nginx_setup
	panel_installation
	enabling_security
	ssh_setup	
 	data_output
	banner_1
 	log_clear
}

### Проверка запуска ###
main_choise() {	
 	if [ -f /usr/local/bin/reinstallation_check ]; then
		clear
  		echo
		msg_err "Повторная установка скрипта"
		sleep 2
		main_script_repeat
		echo
		exit
	else
		clear
		main_script_first
	fi
}

main_choise
