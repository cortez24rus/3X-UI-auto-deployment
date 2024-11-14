#!/usr/bin/env bash

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


E[0]="Language:\n  1.English (default) \n  2.Русский"
R[0]="${E[0]}"
E[1]="Choose:"
R[1]="Выбери:"
E[2]=""
R[2]="Повторная установка скрипта"
E[3]=""
R[3]=""
E[4]=""
R[4]=""
E[5]=""
R[5]=""

warning()    { echo -e "\033[31m\033[01m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp "$(info "$1")" "$2"; }
text()       { eval echo "\${${L}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${L}[$*]}")"; }

log_entry() {
    mkdir -p /usr/local/xui-rp/
    LOGFILE="/usr/local/xui-rp/xui-rp.log"
    exec > >(tee -a "$LOGFILE") 2>&1
}

select_language() {
  echo -e "======================================================================================================================\n"
  L=E && hint " $(text 0) \n" && reading " $(text 1) " LANGUAGE
  [ "$LANGUAGE" = 2 ] && L=R
}

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
    log_entry
    select_language
    clear
    if [ -f /usr/local/xui-rp/reinstallation_check ]; then
        info " $(text 2) "
        sleep 2
        main_script_repeat "$1"
    else
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