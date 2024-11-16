#!/usr/bin/env bash

mkdir -p /usr/local/xui-rp/
LOGFILE="/usr/local/xui-rp/xui-rp.log"

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

function msg_banner()    { echo -e "${Yellow} $1 ${Font}"; }
function msg_ok()        { echo -e "${OK} ${Blue} $1 ${Font}"; }
function msg_err()       { echo -e "${ERROR} ${Orange} $1 ${Font}"; }
function msg_inf()       { echo -e "${QUESTION} ${Yellow} $1 ${Font}"; }
function msg_out()       { echo -e "${Green} $1 ${Font}"; }
function msg_tilda()     { echo -e "${Orange}$1${Font}"; }

exec > >(tee -a "$LOGFILE") 2>&1

# Функция проверки xuibot
check_xuibot() {
    # Если был передан параметр -bot, возвращаем true
    if [[ "$1" == "-bot" ]]; then
        return 0
    else
        return 1
    fi
}

### Продолжение? ###
answer_input() {
    read -r answer
    case "${answer,,}" in
        y) return 0 ;;  # 'y' или 'Y' — продолжить
        *)
            msg_err "ОТМЕНА"
            return 1 ;;  # Для любых других значений — отменить
    esac
}

validate_path() {
	local path_variable_name=$1
	while true; do
		read path_value
		# Удаление пробелов в начале и конце
		path_value=$(echo "$path_value" | sed 's/^[ \t]*//;s/[ \t]*$//')
		# Проверка на пустой ввод
		if [[ -z "$path_value" ]]; then
			msg_err "Ошибка: путь не должен быть пустым"
			echo
			msg_inf "Пожалуйста, введите путь заново:"
		# Проверка на наличие запрещённых символов
		elif [[ $path_value =~ ['{}\$/'] ]]; then
			msg_err "Ошибка: путь не должен содержать символы (/, $, {}, \\)"
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
                echo
                break
                ;;
            *)
                msg_err "Неверный выбор, попробуйте снова"
                ;;
        esac
    done
}

get_test_response() {
    testdomain=$(echo "${domain}" | rev | cut -d '.' -f 1-2 | rev)

    if [[ "$cftoken" =~ [A-Z] ]]; then
        test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "Authorization: Bearer ${cftoken}" --header "Content-Type: application/json")
    else
        test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "X-Auth-Key: ${cftoken}" --header "X-Auth-Email: ${email}" --header "Content-Type: application/json")
    fi
}

# Функция для проверки правильности ответа от API Cloudflare
validate_input() {
    get_test_response

    # Проверка, содержит ли ответ нужные данные
    if [[ "$test_response" =~ "\"${testdomain}\"" && \
          "$test_response" =~ "\"#dns_records:edit\"" && \
          "$test_response" =~ "\"#dns_records:read\"" && \
          "$test_response" =~ "\"#zone:read\"" ]]; then
        return 0
    else
        return 1
    fi
}

# Функция для обрезки домена (удаление http://, https:// и www)
crop_domain() {
    local input_value="$1"   # Считываем переданный домен или reality
    local temp_value          # Временная переменная для обработки

    # Удаление префиксов и www
    temp_value=$(echo "$input_value" | sed -e 's|https\?://||' -e 's|^www\.||' -e 's|/.*$||')

    # Проверка формата домена
    if ! [[ "$temp_value" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$ ]]; then
        echo "Ошибка: введённый адрес '$temp_value' имеет неверный формат."
        return 1
    fi

    # Возвращаем обработанный домен
    echo "$temp_value"
    return 0
}

check_cf_token() {
    while true; do
        while [[ -z $domain ]]; do
            msg_inf "Введите ваш домен:"
            read domain
            echo
        done

        domain=$(crop_domain "$domain")
        
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

reality() {
    while true; do
        while [[ -z $reality ]]; do
            msg_inf "Введите доменное имя, под которое будете маскироваться Reality:"
            read reality
            echo
        done
        
        reality=$(crop_domain "$reality")
        
        if [[ "$reality" == "$domain" ]]; then
            echo "Ошибка: доменное имя для reality не должно совпадать с основным доменом ($domain). Попробуйте снова."
        else
            break
        fi
    done
}

generate_keys() {
    # Генерация пары ключей X25519 с использованием xray
    local key_pair=$(/usr/local/x-ui/bin/xray-linux-amd64 x25519)
    local private_key=$(echo "$key_pair" | grep "Private key:" | awk '{print $3}')
    local public_key=$(echo "$key_pair" | grep "Public key:" | awk '{print $3}')
    
    # Возвращаем ключи в виде строки, разделенной пробелом
    echo "$private_key $public_key"
}

### Проверка IP-адреса ###
check_ip() {
    IP4_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"

    # Попробуем получить IP через ip route
    IP4=$(ip route get 8.8.8.8 2>/dev/null | grep -Po -- 'src \K\S*')

    # Если не получилось, пробуем через curl
    if [[ ! $IP4 =~ $IP4_REGEX ]]; then
    IP4=$(curl -s --max-time 5 ipinfo.io/ip 2>/dev/null)  # Устанавливаем таймаут для curl
    fi

    # Если не удается получить IP, выводим ошибку
    if [[ ! $IP4 =~ $IP4_REGEX ]]; then
        echo "Не удалось определить IP-адрес!"
        return 1
    fi
}

### Проверка рута ###
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Ошибка: для выполнения этого скрипта необходимы права суперпользователя (root)."
        exit 1  # Завершаем выполнение скрипта
    fi
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
    msg_ok "ВНИМАНИЕ!"
    echo
    msg_ok "Перед запуском скрипта рекомендуется выполнить следующие действия:"
    msg_err "apt-get update && apt-get full-upgrade -y && reboot"
    echo
    msg_ok "Начать установку XRAY? Выберите опцию [y/N]"
    answer_input
}

### Ввод данных ###
data_entry() {
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
    msg_inf "Введите имя пользователя:"
    read username
    echo
    msg_inf "Введите пароль пользователя:"
    read password
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
    check_cf_token
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
    msg_inf "Введите sni для Reality:"
    reality
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
    msg_inf "Введите путь к Grpc:"
    validate_path cdngrpc
    echo
    msg_inf "Введите путь к Split:"
    validate_path cdnsplit
    echo
    msg_inf "Введите путь к HttpUpgrade:"
    validate_path cdnhttpu
    echo
    msg_inf "Введите путь к Websocket:"
    validate_path cdnws
    echo
    msg_inf "Введите путь к Node Exporter:"
    validate_path node_metrics
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
    msg_inf "Введите 1, для установки adguard-home (DoH-DoT)"
    msg_inf "Введите 2, для установки systemd-resolved (DoT)"
    choise_dns
    msg_inf "Введите путь к панели (без символов /, $, {}, \):"
    validate_path webBasePath
    echo
    msg_inf "Введите путь к подписке (без символов /, $, {}, \):"
    validate_path subPath
    echo
    msg_inf "Введите путь к JSON подписке (без символов /, $, {}, \):"
    validate_path subJsonPath
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
    if check_xuibot "$1"; then
        msg_inf "Введите токен Telegram бота: "
        read -r BOT_TOKEN
        echo
        msg_inf "Введите ваш Telegram ID:"
        read -r AID
        echo
        msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
        echo
    fi
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
    apt-get update && apt-get upgrade -y && apt-get install -y \
        ufw \
        zip \
        wget \
        sudo \
        curl \
        gnupg2 \
        sqlite3 \
        certbot \
        net-tools \
        apache2-utils \
        unattended-upgrades \
        python3-certbot-dns-cloudflare \
        nginx-full \
        systemd-resolved

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
DNS=1.1.1.1 8.8.8.8 8.8.4.4
#FallbackDNS=
Domains=~.
DNSSEC=yes
DNSOverTLS=yes
EOF
    msg_inf "DNS=1.1.1.1 8.8.8.8 8.8.4.4"
    systemctl restart systemd-resolved.service
}

dns_systemd_resolved_for_adguard() {
    cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
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

    rm -f AdGuardHome/AdGuardHome.yaml
    while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/adh/AdGuardHome.yaml" -O AdGuardHome/AdGuardHome.yaml; do
        msg_err "Скачивание не удалось, пробуем снова..."
        sleep 3
    done
    sed -i "s/\${username}/username/g" AdGuardHome/AdGuardHome.yaml
    sed -i "s/\${hash}/hash/g" AdGuardHome/AdGuardHome.yaml
    sed -i "s/\${username}/domain_temp/g" AdGuardHome/AdGuardHome.yaml
    sed -i "s/\${webCertFile}/fullchain.pem/g" AdGuardHome/AdGuardHome.yaml
    sed -i "s/\${webKeyFile}/privkey.pem/g" AdGuardHome/AdGuardHome.yaml

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
unattended_upgrade() {
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
    bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/warp/xui-rp-warp.sh)
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
    { crontab -l; echo "0 5 1 */2 * certbot -q renew"; } | crontab -
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
    htpasswd -nb "$username" "$password" >> /etc/nginx/.htpasswd

    nginx_conf
    stream_conf
    local_conf
    random_site

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
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

#   access_log                    /var/log/nginx/access.log  main;
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

    gzip                          on;

    include                       /etc/nginx/conf.d/*.conf;
}

stream {
    include /etc/nginx/stream-enabled/stream.conf;
}
EOF
}

stream_conf() {
    cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_protocol \$backend {
    default \$https;
    "" ssh;
}
map \$ssl_preread_server_name \$https {
    ${domain}      web;
    ${reality}     reality;
    www.${domain}  xtls;
}
upstream web             { server 127.0.0.1:7443; }
#upstream web             { server 127.0.0.1:46076; }
upstream reality         { server 127.0.0.1:8443; }
upstream xtls            { server 127.0.0.1:9443; }
#upstream ssh             { server 127.0.0.1:36079; }

server {
    listen 443           reuseport;
    ssl_preread          on;
    proxy_pass           \$backend;
}
EOF
}

local_conf() {
    cat > /etc/nginx/conf.d/local.conf <<EOF
server {
     listen 9090 default_server;
     server_name _;
     location / {
         return 301  https://${domain}\$request_uri;
     }
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
#    listen                      46076 ssl http2;
    listen                      46076 ssl http2 proxy_protocol;
    set_real_ip_from            127.0.0.1;
    real_ip_header              proxy_protocol;
    server_name                 ${domain} www.${domain};

    # SSL
    ssl_certificate             ${webCertFile};
    ssl_certificate_key         ${webKeyFile};
    ssl_trusted_certificate     /etc/letsencrypt/live/${domain}/chain.pem;

    index index.html index.htm index.php index.nginx-debian.html;
    root /var/www/html/;

    # Security headers
    add_header X-XSS-Protection          "1; mode=block" always;
    add_header X-Content-Type-Options    "nosniff" always;
    add_header Referrer-Policy           "no-referrer-when-downgrade" always;
#    add_header Content-Security-Policy   "default-src https:; script-src https: 'unsafe-inline' 'unsafe-eval'; style-src https: 'unsafe-inline';" always;
    add_header Permissions-Policy        "interest-cohort=()" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
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

#    location / {
#        auth_basic "Restricted Content";
#        auth_basic_user_file /etc/nginx/.htpasswd;
#    }
     location /${node_metrics} {
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://127.0.0.1:9100/metrics;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    location ~* /(sub|dashboard|api|docs|redoc|openapi.json|statics) {
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass https://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
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
    location /${cdnsplit} {
        proxy_pass http://127.0.0.1:2063;
        proxy_http_version 1.1;
        proxy_redirect off;
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

random_site() {
    bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-random-site.sh)
}

monitoring() {
    bash <(curl -Ls https://github.com/cortez24rus/grafana-prometheus/raw/refs/heads/main/prometheus_node_exporter.sh)
}

### Установка 3x-ui ###
panel_installation() {
    touch /usr/local/xui-rp/reinstallation_check
    msg_inf "Настройка 3x-ui xray"
    while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/other/x-ui.gpg; do
        msg_err "Скачивание не удалось, пробуем снова..."
        sleep 3
    done
    echo ${password} | gpg --batch --yes --passphrase-fd 0 -d x-ui.gpg > x-ui.db
    echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) > /dev/null 2>&1

    stream_settings_grpc
    stream_settings_split
    stream_settings_httpu
    stream_settings_ws
    stream_settings_steal
    stream_settings_reality
    stream_settings_xtls
    stream_settings_mkcp
    database_change

    x-ui stop
    
    rm -rf x-ui.gpg
    [ -f /etc/x-ui/x-ui.db ] && mv /etc/x-ui/x-ui.db /etc/x-ui/x-ui.db.backup
    mv x-ui.db /etc/x-ui/
    
    x-ui start
    echo -e "20\n1" | x-ui > /dev/null 2>&1
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
}

### Изменение базы данных ###
stream_settings_grpc() {
    stream_settings_grpc=$(cat <<EOF
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

stream_settings_split() {
    stream_settings_split=$(cat <<EOF
{
  "network": "splithttp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "splithttpSettings": {
    "path": "/${cdnsplit}",
    "host": "",
    "headers": {},
    "scMaxConcurrentPosts": "100-200",
    "scMaxEachPostBytes": "1000000-2000000",
    "scMinPostsIntervalMs": "10-50",
    "noSSEHeader": false,
    "xPaddingBytes": "100-1000",
    "xmux": {
      "maxConcurrency": "16-32",
      "maxConnections": 0,
      "cMaxReuseTimes": "64-128",
      "cMaxLifetimeMs": 0
    }
  }
}
EOF
)
}

stream_settings_httpu() {
    stream_settings_httpu=$(cat <<EOF
{
  "network": "httpupgrade",
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
    "serverName": "",
    "minVersion": "1.2",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
        "certificateFile": "${webCertFile}",
        "keyFile": "${webKeyFile}",
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
  "httpupgradeSettings": {
    "acceptProxyProtocol": false,
    "path": "/2073/${cdnhttpu}",
    "host": "${domain}",
    "headers": {}
  }
}
EOF
)
}

stream_settings_ws() {
    stream_settings_ws=$(cat <<EOF
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
        "certificateFile": "${webCertFile}",
        "keyFile": "${webKeyFile}",
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
    "path": "/2083/${cdnws}",
    "host": "${domain}",
    "headers": {}
  }
}
EOF
)
}

stream_settings_steal() {
    read private_key public_key <<< "$(generate_keys)"

    stream_settings_steal=$(cat <<EOF
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
    "xver": 2,
    "dest": "46076",
    "serverNames": [
      "${domain}"
    ],
    "privateKey": "${private_key}",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "22dff0",
      "0041e9ca",
      "49afaa139d",
      "89",
      "1addf92cc1bd50",
      "6e122954e9df",
      "8d93026df5de065c",
      "bc85"
    ],
    "settings": {
      "publicKey": "${public_key}",
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

stream_settings_reality() {
    read private_key public_key <<< "$(generate_keys)"

    stream_settings_reality=$(cat <<EOF
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
    "xver": 2,
    "dest": "${reality}:443",
    "serverNames": [
      "${reality}"
    ],
    "privateKey": "${private_key}",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "cd95c9",
      "eeed8008",
      "f2e26eba6c9432cf",
      "0d6a8b47988f0d",
      "c1",
      "1b60e7369779",
      "7fb9d5f9d8",
      "6696"
    ],
    "settings": {
      "publicKey": "${public_key}",
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

stream_settings_xtls() {
    stream_settings_xtls=$(cat <<EOF
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
    "minVersion": "1.3",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
        "certificateFile": "${webCertFile}",
        "keyFile": "${webKeyFile}",
        "ocspStapling": 3600,
        "oneTimeLoading": false,
        "usage": "encipherment",
        "buildChain": false
      }
    ],
    "alpn": [
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

stream_settings_mkcp() {
    stream_settings_mkcp=$(cat <<EOF
{
  "network": "kcp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 9999,
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
    "seed": "iTsaMjully"
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

UPDATE inbounds SET stream_settings = '$stream_settings_grpc' WHERE remark = '☁gRPC';
UPDATE inbounds SET stream_settings = '$stream_settings_split' WHERE remark = '☁Split';
UPDATE inbounds SET stream_settings = '$stream_settings_httpu' WHERE remark = '☁HttpU';
UPDATE inbounds SET stream_settings = '$stream_settings_ws' WHERE remark = '☁WS';
UPDATE inbounds SET stream_settings = '$stream_settings_steal' WHERE remark = '🥷🏻Steal';
UPDATE inbounds SET stream_settings = '$stream_settings_reality' WHERE remark = '🥷🏻Whatsapp';
UPDATE inbounds SET stream_settings = '$stream_settings_xtls' WHERE remark = '✖️XTLS';
UPDATE inbounds SET stream_settings = '$stream_settings_mkcp' WHERE remark = '📲MKCP';

UPDATE settings SET value = '${webPort}' WHERE key = 'webPort';
UPDATE settings SET value = '/${webBasePath}/' WHERE key = 'webBasePath';
UPDATE settings SET value = '${webCertFile}' WHERE key = 'webCertFile';
UPDATE settings SET value = '${webKeyFile}' WHERE key = 'webKeyFile';
UPDATE settings SET value = '${subPort}' WHERE key = 'subPort';
UPDATE settings SET value = '/${subPath}/' WHERE key = 'subPath';
UPDATE settings SET value = '${webCertFile}' WHERE key = 'subCertFile';
UPDATE settings SET value = '${webKeyFile}' WHERE key = 'subKeyFile';
UPDATE settings SET value = '${subURI}' WHERE key = 'subURI';
UPDATE settings SET value = '/${subJsonPath}/' WHERE key = 'subJsonPath';
UPDATE settings SET value = '${subJsonURI}' WHERE key = 'subJsonURI';
EOF
}

### UFW ###
enabling_security() {
    msg_inf "Настройка ufw"
    ufw --force reset
    ufw allow 36079/tcp
    ufw allow 443/tcp
    ufw allow 22/tcp
    ufw insert 1 deny from $(echo ${IP4} | cut -d '.' -f 1-3).0/22
    ufw --force enable
    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
}

### SSH ####
ssh_setup() {
    exec > /dev/tty 2>&1
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
    while true; do
        msg_inf "Настроить ssh (шаг не обязательный)? [y/N]"
        answer_input

        if [[ $? -eq 0 ]]; then

            if [[ ! -s /home/${username}/.ssh/id_rsa.pub && ! -s /root/.ssh/id_rsa.pub ]]; then
                msg_err "Ошибка: Ключи не найдены в файле /home/${username}/.ssh/id_rsa.pub или /root/.ssh/id_rsa.pub"
                msg_err "Cоздайте ключи и добавьте их на сервер, прежде чем продолжить"
                msg_inf "Попробуйте снова"
                echo
            else
                # Если ключи найдены, продолжаем настройку SSH
                sed -i -e "
                    s/#Port/Port/g;
                    s/Port 22/Port 36079/g;
                    s/#PermitRootLogin/PermitRootLogin/g;
                    s/PermitRootLogin yes/PermitRootLogin prohibit-password/g;
                    s/#PubkeyAuthentication/PubkeyAuthentication/g;
                    s/PubkeyAuthentication no/PubkeyAuthentication yes/g;
                    s/#PasswordAuthentication/PasswordAuthentication/g;
                    s/PasswordAuthentication yes/PasswordAuthentication no/g;
                    s/#PermitEmptyPasswords/PermitEmptyPasswords/g;
                    s/PermitEmptyPasswords yes/PermitEmptyPasswords no/g;
                " /etc/ssh/sshd_config
                
                cat > /etc/motd <<EOF

################################################################################
                         WARNING: AUTHORIZED ACCESS ONLY
################################################################################

This system is for the use of authorized users only. Individuals using this
computer system without authority, or in excess of their authority, are subject
to having all of their activities on this system monitored and recorded.

Any unauthorized access or use of this system is prohibited and may be subject
to criminal and/or civil penalties. All activities on this system are logged
and monitored. By accessing this system, you agree to comply with all applicable
company policies, and you consent to the monitoring and recording of your
activities.

If you are not an authorized user, you must disconnect immediately.

Unauthorized access to this device is strictly prohibited and will be prosecuted
to the fullest extent of the law.

################################################################################

             +----------------------------------------------------+
             | █████ █████ ███████████     █████████   █████ █████|
             |░░███ ░░███ ░░███░░░░░███   ███░░░░░███ ░░███ ░░███ |
             | ░░███ ███   ░███    ░███  ░███    ░███  ░░███ ███  |
             |  ░░█████    ░██████████   ░███████████   ░░█████   |
             |   ███░███   ░███░░░░░███  ░███░░░░░███    ░░███    |
             |  ███ ░░███  ░███    ░███  ░███    ░███     ░███    |
             | █████ █████ █████   █████ █████   █████    █████   |
             |░░░░░ ░░░░░ ░░░░░   ░░░░░ ░░░░░   ░░░░░    ░░░░░    |
             +----------------------------------------------------+


EOF
                systemctl restart ssh.service
                echo "Настройка SSH завершена."
                break
            fi
        else
            echo "Настройка SSH пропущена."
            break
        fi
    done

    echo
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo
}

# Установока xui бота
install_xuibot() {
    if [[ "$1" == "-bot" ]]; then
         bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install-bot.sh) "$BOT_TOKEN" "$AID" "$domain"
    fi
}

### Окончание ###
data_output() {
    msg_err "PLEASE SAVE THIS SCREEN!"
    printf '0\n' | x-ui | grep --color=never -i ':'
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo -n "Доступ по ссылке к 3x-ui панели: " && msg_out "https://${domain}/${webBasePath}/"
    echo -n "Быстрая ссылка, на подписку, для подключения: " && msg_out "${subURI}user"
    if [[ $choise = "1" ]]; then
        echo -n "Доступ по ссылке к adguard-home: " && msg_out "https://${domain}/${adguardPath}/login.html"
    fi
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo -n "Подключение по ssh: " && msg_out "ssh -p 36079 ${username}@${IP4}"
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo -n "Username: " && msg_out "$username"
    echo -n "Password: " && msg_out "$password"
    msg_tilda "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo -n "Путь к лог файлу: " && msg_out "$LOGFILE"
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
    data_entry "$1"
    installation_of_utilities
    dns_encryption
    add_user
    unattended_upgrade
    enable_bbr
    disable_ipv6
    warp
    issuance_of_certificates
    monitoring
    nginx_setup
    panel_installation
    enabling_security
    ssh_setup
    install_xuibot "$1"
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
    data_entry "$1"
    dns_encryption
    nginx_setup
    panel_installation
    enabling_security
    ssh_setup
    install_xuibot "$1"
    data_output
    banner_1
    log_clear
}

### Проверка запуска ###
main_choise() {
    if [ -f /usr/local/xui-rp/reinstallation_check ]; then
        clear
        echo
        msg_err "Повторная установка скрипта"
        sleep 2
        main_script_repeat "$1"
        echo
        exit
    else
        clear
        main_script_first "$1"
    fi
}

main_choise "$1"




#location /adguard-home/ {
#    proxy_pass http://127.0.0.1:8081/;
#    proxy_redirect / /adguard-home/;
#    proxy_cookie_path / /adguard-home/;
#}


#location ~* /(admin|api|dashboard|openapi.json|statics|docs) {
#    proxy_redirect off;
#    proxy_http_version 1.1;
#    proxy_set_header Upgrade \$http_upgrade;
#    proxy_set_header Connection "upgrade";
#    proxy_pass http://127.0.0.1:8081/;
    
#    proxy_set_header Host \$host;
#    proxy_set_header X-Real-IP \$remote_addr;
#    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#}