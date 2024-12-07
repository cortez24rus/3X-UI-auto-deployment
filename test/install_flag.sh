#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

### INFO ###
out_data()   { echo -e "\e[1;33m$1\033[0m \033[1;37m$2\033[0m"; }
tilda()      { echo -e "\033[31m\033[38;5;214m$*\033[0m"; }
warning()    { echo -e "\033[31m [!]\033[38;5;214m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; exit 1; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
question()   { echo -e "\033[32m[?]\e[1;33m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp " $(question "$1")" "$2"; }
text()       { eval echo "\${${L}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${L}[$*]}")"; }

E[0]="Language:\n  1. English (default) \n  2. Русский"
R[0]="Язык:\n  1. English (по умолчанию) \n  2. Русский"
E[1]="Choose:"
R[1]="Выбери:"
E[2]="Error: this script requires superuser (root) privileges to run."
R[2]="Ошибка: для выполнения этого скрипта необходимы права суперпользователя (root)."
E[3]="Unable to determine IP address."
R[3]="Не удалось определить IP-адрес."
E[4]="Reinstalling script..."
R[4]="Повторная установка скрипта..."
E[5]="WARNING!"
R[5]="ВНИМАНИЕ!"
E[6]="It is recommended to perform the following actions before running the script"
R[6]="Перед запуском скрипта рекомендуется выполнить следующие действия"
E[7]="Annihilation of the system!"
R[7]="Анигиляция системы!"
E[8]="Start the XRAY installation? Choose option [y/N]:"
R[8]="Начать установку XRAY? Выберите опцию [y/N]:"
E[9]="CANCEL"
R[9]="ОТМЕНА"
E[10]="\n|-----------------------------------------------------------------------------|\n"
R[10]="\n|-----------------------------------------------------------------------------|\n"
E[11]="Enter username:"
R[11]="Введите имя пользователя:"
E[12]="Enter user password:"
R[12]="Введите пароль пользователя:"
E[13]="Enter your domain:"
R[13]="Введите ваш домен:"
E[14]="Error: the entered address '$temp_value' is incorrectly formatted."
R[14]="Ошибка: введённый адрес '$temp_value' имеет неверный формат."
E[15]="Enter your email registered with Cloudflare:"
R[15]="Введите вашу почту, зарегистрированную на Cloudflare:"
E[16]="Enter your Cloudflare API token (Edit zone DNS) or global API key:"
R[16]="Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:"
E[17]="Verifying domain, API token/key, and email..."
R[17]="Проверка домена, API токена/ключа и почты..."
E[18]="Error: invalid domain, API token/key, or email. Please try again."
R[18]="Ошибка: неправильно введён домен, API токен/ключ или почта. Попробуйте снова."
E[19]="Enter SNI for Reality:"
R[19]="Введите sni для Reality:"
E[20]="Enter Grpc path:"
R[20]="Введите путь к Grpc:"
E[21]="Enter Split path:"
R[21]="Введите путь к Split:"
E[22]="Enter HttpUpgrade path:"
R[22]="Введите путь к HttpUpgrade:"
E[23]="Enter Websocket path:"
R[23]="Введите путь к Websocket:"
E[24]="Enter Node Exporter path:"
R[24]="Введите путь к Node Exporter:"
E[25]="Enter Adguard-home path:"
R[25]="Введите путь к Adguard-home:"
E[26]="Enter panel path:"
R[26]="Введите путь к панели:"
E[27]="Enter subscription path:"
R[27]="Введите путь к подписке:"
E[28]="Enter JSON subscription path:"
R[28]="Введите путь к JSON подписке:"
E[29]="Error: path cannot be empty, please re-enter."
R[29]="Ошибка: путь не может быть пустым, повторите ввод."
E[30]="Error: path must not contain characters {, }, /, $, \\, please re-enter."
R[30]="Ошибка: путь не должен содержать символы {, }, /, $, \\, повторите ввод."
E[31]="DNS server:\n  1. Systemd-resolved \n  2. Adguard-home"
R[31]="DNS сервер:\n  1. Systemd-resolved \n  2. Adguard-home"
E[32]="Systemd-resolved selected."
R[32]="Выбран systemd-resolved."
E[33]="Error: invalid choice, please try again."
R[33]="Ошибка: неверный выбор, попробуйте снова."
E[34]="Enter the Telegram bot token for the control panel:"
R[34]="Введите токен Telegram бота для панели управления:"
E[35]="Enter your Telegram ID:"
R[35]="Введите ваш Telegram ID:"
E[36]="Updating system and installing necessary packages."
R[36]="Обновление системы и установка необходимых пакетов."
E[37]="Configuring DNS."
R[37]="Настройка DNS."
E[38]="Download failed, retrying..."
R[38]="Скачивание не удалось, пробуем снова..."
E[39]="Adding user."
R[39]="Добавление пользователя."
E[40]="Enabling automatic security updates."
R[40]="Автоматическое обновление безопасности."
E[41]="Enabling BBR."
R[41]="Включение BBR."
E[42]="Disabling IPv6."
R[42]="Отключение IPv6."
E[43]="Configuring WARP."
R[43]="Настройка WARP."
E[44]="Issuing certificates."
R[44]="Выдача сертификатов."
E[45]="Configuring NGINX."
R[45]="Настройка NGINX."
E[46]="Setting up a panel for Xray."
R[46]="Настройка панели для Xray."
E[47]="Configuring UFW."
R[47]="Настройка UFW."
E[48]="Configuring SSH."
R[48]="Настройка SSH."
E[49]="Generate a key for your OS (ssh-keygen)."
R[49]="Сгенерируйте ключ для своей ОС (ssh-keygen)."
E[50]="In Windows, install the openSSH package and enter the command in PowerShell (recommended to research key generation online)."
R[50]="В Windows нужно установить пакет openSSH и ввести команду в PowerShell (рекомендуется изучить генерацию ключей в интернете)."
E[51]="If you are on Linux, you probably know what to do C:"
R[51]="Если у вас Linux, то вы сами все умеете C:"
E[52]="Command for Windows:"
R[52]="Команда для Windows:"
E[53]="Command for Linux:"
R[53]="Команда для Linux:"
E[54]="Configure SSH (optional step)? [y/N]:"
R[54]="Настроить SSH (необязательный шаг)? [y/N]:"
E[55]="Error: Keys not found. Please add them to the server before retrying..."
R[55]="Ошибка: ключи не найдены, добавьте его на сервер, прежде чем повторить..."
E[56]="Key found, proceeding with SSH setup."
R[56]="Ключ найден, настройка SSH."
E[57]="Installing bot."
R[57]="Установка бота."
E[58]="SAVE THIS SCREEN!"
R[58]="СОХРАНИ ЭТОТ ЭКРАН!"
E[59]="Access the panel at the link:"
R[59]="Доступ по ссылке к панели:"
E[60]="Quick subscription link for connection:"
R[60]="Быстрая ссылка на подписку для подключения:"
E[61]="Access Adguard-home at the link:"
R[61]="Доступ по ссылке к adguard-home:"
E[62]="SSH connection:"
R[62]="Подключение по SSH:"
E[63]="Username:"
R[63]="Имя пользователя:"
E[64]="Password:"
R[64]="Пароль:"
E[65]="Log file path:"
R[65]="Путь к лог файлу:"
E[66]="Prometheus monitor."
R[66]="Мониторинг Prometheus."
E[67]="Set up the Telegram bot? [y/N]:"
R[67]="Настроить telegram бота? [y/N]:"
E[68]="Bot:\n  1. IP limit (default) \n  2. Torrent ban"
R[68]="Бот:\n  1. IP limit (по умолчанию) \n  2. Torrent ban"
E[69]="Enter the Telegram bot token for IP limit, Torrent ban:"
R[69]="Введите токен Telegram бота для IP limit, Torrent ban:"
E[70]="Secret key:"
R[70]="Секретный ключ:"
E[71]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/cortez24rus/xui-reverse-proxy/issues]"
R[71]="Текущая операционная система: \$SYS.\\\n Система с версией ниже, чем \$SYSTEM \${MAJOR[int]}, не поддерживается. Обратная связь: [https://github.com/cortez24rus/xui-reverse-proxy/issues]"
E[72]="Install dependence-list:"
R[72]="Список зависимостей для установки:"
E[73]="All dependencies already exist and do not need to be installed additionally."
R[73]="Все зависимости уже установлены и не требуют дополнительной установки."
E[74]="OS - $SYS"
R[74]="OS - $SYS"

declare -A defaults
declare -A args
defaults_file="/usr/local/xui-rp/reinstall_defaults.conf"

# Функция для отображения справки
show_help() {
  echo ""
  echo "Usage: $0 [-f|--utils <true|false>] [-d|--dns <true|false>] [-a|--addu <true|false>] [-r|--autoupd <true|false>]"
  echo "       [-b|--bbr <true|false>] [-i|--ipv6 <true|false>] [-w|--warp <true|false>] [-c|--cert <true|false>]"
  echo "       [-m|--mon <true|false>] [-n|--nginx <true|false>] [-p|--panel <true|false>] [-u|--ufw <true|false>]"
  echo "       [-s|--ssh <true|false>] [-t|--tgbot <true|false>] [-h|--help]"
  echo ""
  echo "  -f, --utils <true|false>        Enable or disable utilities (default: ${defaults[utils]})"
  echo "  -d, --dns <true|false>          Enable or disable DNS encryption (default: ${defaults[dns]})"
  echo "  -a, --addu <true|false>         Enable or disable user addition (default: ${defaults[addu]})"
  echo "  -r, --autoupd <true|false>      Enable or disable automatic updates (default: ${defaults[autoupd]})"
  echo "  -b, --bbr <true|false>          Enable or disable BBR (default: ${defaults[bbr]})"
  echo "  -i, --ipv6 <true|false>         Enable or disable IPv6 (default: ${defaults[ipv6]})"
  echo "  -w, --warp <true|false>         Enable or disable Warp (default: ${defaults[warp]})"
  echo "  -c, --cert <true|false>         Enable or disable certificate issuance (default: ${defaults[cert]})"
  echo "  -m, --mon <true|false>          Enable or disable Monitoring (default: ${defaults[mon]})"
  echo "  -n, --nginx <true|false>        Enable or disable NGINX installation (default: ${defaults[nginx]})"
  echo "  -p, --panel <true|false>        Enable or disable panel installation (default: ${defaults[panel]})"
  echo "  -u, --ufw <true|false>          Enable or disable UFW (default: ${defaults[ufw]})"
  echo "  -s, --ssh <true|false>          Enable or disable SSH (default: ${defaults[ssh]})"
  echo "  -t, --tgbot <true|false>        Enable or disable Telegram bot (default: ${defaults[tgbot]})"
  echo "  -h, --help                      Display this help message"
  echo ""
  exit 0
}

# Функция для чтения значений из файла
read_defaults_from_file() {
  if [[ -f $defaults_file ]]; then
    # Чтение и выполнение строк из файла
    while IFS= read -r line; do
      # Пропускаем пустые строки и комментарии
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      eval "$line"
    done < $defaults_file
  else
    # Если файл не найден, используем значения по умолчанию
    defaults[utils]=true
    defaults[dns]=true
    defaults[addu]=true
    defaults[autoupd]=true
    defaults[bbr]=true
    defaults[ipv6]=true
    defaults[warp]=true
    defaults[cert]=true
    defaults[mon]=false
    defaults[nginx]=true
    defaults[panel]=true
    defaults[ufw]=true
    defaults[ssh]=true
    defaults[tgbot]=false
  fi
}

# Функция для записи значений в файл
write_defaults_to_file() {
  cat > ${defaults_file}<<EOF
defaults[utils]=false
defaults[dns]=false
defaults[addu]=false
defaults[autoupd]=false
defaults[bbr]=false
defaults[ipv6]=false
defaults[warp]=false
defaults[cert]=false
defaults[mon]=false
defaults[nginx]=true
defaults[panel]=true
defaults[ufw]=false
defaults[ssh]=true
defaults[tgbot]=false
EOF
}

normalize_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

# Функция для проверки правильности значения true/false
validate_true_false() {
  local key=$1
  local value=$2
  case ${value} in
    true)
      args[$key]=true
      ;;
    false)
      args[$key]=false
      ;;
    *)
      echo "Invalid option for --$key: $value. Use 'true' or 'false'."
      return 1
      ;;
  esac
}

parse_args() {
  local opts
  opts=$(getopt -o i:w:m:u:s:t:f:a:r:b:h:l:d:p:c:n --long utils:,dns:,addu:,autoupd:,bbr:,ipv6:,warp:,cert:,mon:,nginx:,panel:,ufw:,ssh:,tgbot:,help -- "$@")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  eval set -- "$opts"
  while true; do
    case $1 in
      -f|--utils)
        args[utils]="$2"
        normalize_case utils
        validate_true_false utils "$2" || return 1
        shift 2
        ;;
      -d|--dns)
        args[dns]="$2"
        normalize_case dns
        validate_true_false dns "$2" || return 1
        shift 2
        ;;
      -a|--addu)
        args[addu]="$2"
        normalize_case addu
        validate_true_false addu "$2" || return 1
        shift 2
        ;;
      -r|--autoupd)
        args[autoupd]="$2"
        normalize_case autoupd
        validate_true_false autoupd "$2" || return 1
        shift 2
        ;;
      -b|--bbr)
        args[bbr]="$2"
        normalize_case bbr
        validate_true_false bbr "$2" || return 1
        shift 2
        ;;
      -i|--ipv6)
        args[ipv6]="$2"
        normalize_case ipv6
        validate_true_false ipv6 "$2" || return 1
        shift 2
        ;;
      -w|--warp)
        args[warp]="$2"
        normalize_case warp
        validate_true_false warp "$2" || return 1
        shift 2
        ;;
      -c|--cert)
        args[cert]="$2"
        normalize_case cert
        validate_true_false cert "$2" || return 1
        shift 2
        ;;
      -m|--mon)
        args[mon]="$2"
        normalize_case mon
        validate_true_false mon "$2" || return 1
        shift 2
        ;;
      -n|--nginx)
        args[nginx]="$2"
        normalize_case nginx
        validate_true_false nginx "$2" || return 1
        shift 2
        ;;
      -p|--panel)
        args[panel]="$2"
        normalize_case panel
        validate_true_false panel "$2" || return 1
        shift 2
        ;;
      -u|--ufw)
        args[ufw]="$2"
        normalize_case ufw
        validate_true_false ufw "$2" || return 1
        shift 2
        ;;
      -s|--ssh)
        args[ssh]="$2"
        normalize_case ssh
        validate_true_false ssh "$2" || return 1
        shift 2
        ;;
      -t|--tgbot)
        args[tgbot]="$2"
        normalize_case tgbot
        validate_true_false tgbot "$2" || return 1
        shift 2
        ;;
      -h|--help)
        return 1
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done
  
  for key in "${!defaults[@]}"; do
    if [[ -z "${args[$key]}" ]]; then
      args[$key]=${defaults[$key]}
    fi
  done
}

# Логирование
log_entry() {
  mkdir -p /usr/local/xui-rp/
  LOGFILE="/usr/local/xui-rp/xui-rp.log"
  exec > >(tee -a "$LOGFILE") 2>&1
}

# Выбор языка
select_language() {
  L=E
  hint " $(text 0) \n"  # Показывает информацию о доступных языках
  reading " $(text 1) " LANGUAGE  # Запрашивает выбор языка

  # Устанавливаем язык в зависимости от выбора
  case "$LANGUAGE" in
  1) L=E ;;   # Если выбран английский
  2) L=R ;;   # Если выбран русский
#  3) L=C ;;   # Если выбран китайский
#  4) L=F ;;   # Если выбран персидский
  *) L=E ;;   # По умолчанию — английский
  esac
}

### Проверка рута ###
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error " $(text 8) "
  fi
}

# Многоступенчатая проверка операционной системы, пробуем до тех пор, пока не получим значение. Поддерживаются только Debian 10/11, Ubuntu 18.04/20.04 или CentOS 7/8. Если это не одна из перечисленных операционных систем, скрипт завершится.
# Благодарность котику за техническую помощь и оптимизацию повторяющихся команд. https://github.com/Oreomeow
check_operating_system() {
  if [ -s /etc/os-release ]; then
    SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  elif [ -x "$(type -p hostnamectl)" ]; then
    SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  elif [ -x "$(type -p lsb_release)" ]; then
    SYS="$(lsb_release -sd)"
  elif [ -s /etc/lsb-release ]; then
    SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  elif [ -s /etc/redhat-release ]; then
    SYS="$(grep . /etc/redhat-release)"
  elif [ -s /etc/issue ]; then
    SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"
  fi

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky")
  RELEASE=("Debian" "Ubuntu" "CentOS")
  EXCLUDE=("---")
  MAJOR=("9" "16" "7")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update --skip-broken")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  # Проверка на кастомизированные системы от различных производителей
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  # Определение основной версии Linux
  MAJOR_VERSION=$(sed "s/[^0-9.]//g" <<< "$SYS" | cut -d. -f1)

  # Сначала исключаем системы, указанные в EXCLUDE, затем для оставшихся делаем сравнение по основной версии
  for ex in "${EXCLUDE[@]}"; do [[ ! "${SYS,,}" =~ $ex ]]; done &&
  [[ "$MAJOR_VERSION" -lt "${MAJOR[int]}" ]] && error " $(text 71) "
  echo "SYS $SYS"
  echo "REGEX ${REGEX[int]}"
  echo "RELEASE ${RELEASE[int]}"
  echo "MAJOR ${MAJOR[int]}"
  echo "PACKAGE_UPDATE ${PACKAGE_UPDATE[int]}"
  echo "SYSTEM ${SYSTEM[int]}"
  echo "MAJOR_VERSION ${MAJOR_VERSION[int]}"
}

check_dependencies() {
  # Зависимости, необходимые для трех основных систем
  DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip")
  DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2")

  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=(${DEPS_INSTALL[g]})
  done

  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 72) ${DEPS[@]} \n"
    ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
  else
    info "\n $(text 73) \n"
  fi
}
#wget -N https://git && bash .sh d

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
    error " $(text 3)"
    return 1
  fi
}

### Баннер ###
banner_1() {
  echo
  echo " █░█ █░░█ ░▀░ ░░ █▀▀█ █▀▀ ▀█░█▀ █▀▀ █▀▀█ █▀▀ █▀▀ ░░ █▀▀█ █▀▀█ █▀▀█ █░█ █░░█  "
  echo " ▄▀▄ █░░█ ▀█▀ ▀▀ █▄▄▀ █▀▀ ░█▄█░ █▀▀ █▄▄▀ ▀▀█ █▀▀ ▀▀ █░░█ █▄▄▀ █░░█ ▄▀▄ █▄▄█  "
  echo " ▀░▀ ░▀▀▀ ▀▀▀ ░░ ▀░▀▀ ▀▀▀ ░░▀░░ ▀▀▀ ▀░▀▀ ▀▀▀ ▀▀▀ ░░ █▀▀▀ ▀░▀▀ ▀▀▀▀ ▀░▀ ▄▄▄█  "
  echo
  echo
}

### Начало установки ###
start_installation() {
  warning " $(text 5) "
  echo
  info " $(text 6) "
  warning " apt-get update && apt-get full-upgrade -y && reboot "
  echo
  reading " $(text 8) " ANSWER_START
  case "${ANSWER_START,,}" in
    y|"")
	  ;;
    *)
      error " $(text 9) "
      ;;
  esac
}

# Функция для обрезки домена (удаление http://, https:// и www)
crop_domain() {
  local input_value="$1"
  local temp_value
  temp_value=$(echo "$input_value" | sed -e 's|https\?://||' -e 's|/.*$||')
  
  if ! [[ "$temp_value" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$ ]]; then
    echo "Ошибка: введённый адрес '$temp_value' имеет неверный формат."
    return 1
  fi

  local multi_level_domains=("co.uk" "com.au" "gov.ru" "edu.ru" "org.uk" "net.uk" "gov.uk" "co.in" "com.br" "org.br")
  IFS='.' read -r -a domain_parts <<< "$temp_value"
  local domain_second_level="${domain_parts[-2]}.${domain_parts[-1]}"
  
  for tld in "${multi_level_domains[@]}"; do
    if [[ "$domain_second_level" == "$tld" ]]; then
      echo "${domain_parts[-3]}.${domain_second_level}"
      return 0
    fi
  done

  echo "$domain_second_level"
  return 0
}

# Запрос и ответ от API Cloudflare
get_test_response() {
  testdomain=$(echo "${DOMAIN}" | rev | cut -d '.' -f 1-2 | rev)

  if [[ "$CFTOKEN" =~ [A-Z] ]]; then
    test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "Authorization: Bearer ${CFTOKEN}" --header "Content-Type: application/json")
  else
    test_response=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "X-Auth-Key: ${CFTOKEN}" --header "X-Auth-Email: ${EMAIL}" --header "Content-Type: application/json")
  fi
}

check_cf_token() {
  while ! echo "$test_response" | grep -qE "\"${testdomain}\"|\"#dns_records:edit\"|\"#dns_records:read\"|\"#zone:read\""; do
    DOMAIN=""
    EMAIL=""
    CFTOKEN=""
    while [[ -z $DOMAIN ]]; do
      reading " $(text 13) " DOMAIN
	  echo ${DOMAIN}
      echo
    done

    DOMAIN=$(crop_domain "$DOMAIN")
    
    if [[ $? -ne 0 ]]; then
      DOMAIN=""
      continue
    fi

    while [[ -z $EMAIL ]]; do
      reading " $(text 15) " EMAIL
      echo
    done

    while [[ -z $CFTOKEN ]]; do
      reading " $(text 16) " CFTOKEN
      echo
    done
    get_test_response
    info " $(text 17) "
  done
}

# Функция для обработки пути с циклом
validate_path() {
  local VARIABLE_NAME="$1"
  local PATH_VALUE

  # Проверка на пустое значение
  while true; do
    case "$VARIABLE_NAME" in
      CDNGRPC)
        reading " $(text 20) " PATH_VALUE
        ;;
      CDNSPLIT)
        reading " $(text 21) " PATH_VALUE
        ;;
      CDNHTTPU)
        reading " $(text 22) " PATH_VALUE
        ;;
      CDNWS)
        reading " $(text 23) " PATH_VALUE
        ;;
      METRICS)
        reading " $(text 24) " PATH_VALUE
        ;;
      ADGUARDPATH)
        reading " $(text 25) " PATH_VALUE
        ;;
      WEB_BASE_PATH)
        reading " $(text 26) " PATH_VALUE
        ;;
      SUB_PATH)
        reading " $(text 27) " PATH_VALUE
        ;;                
      SUB_JSON_PATH)
        reading " $(text 28) " PATH_VALUE
        ;;        
    esac

    if [[ -z "$PATH_VALUE" ]]; then
      warning " $(text 29) "
      echo
    elif [[ $PATH_VALUE =~ ['{}\$/\\'] ]]; then
      warning " $(text 30) "
      echo
    else
      break
    fi
  done

  case "$VARIABLE_NAME" in
    CDNGRPC)
      export CDNGRPC="$PATH_VALUE"
      ;;
    CDNSPLIT)
      export CDNSPLIT="$PATH_VALUE"
      ;;
    CDNHTTPU)
      export CDNHTTPU="$PATH_VALUE"
      ;;
    CDNWS)
      export CDNWS="$PATH_VALUE"
      ;;
    METRICS)
      export METRICS="$PATH_VALUE"
      ;;
    ADGUARDPATH)
      export ADGUARDPATH="$PATH_VALUE"
      ;;
    WEB_BASE_PATH)
      export WEB_BASE_PATH="$PATH_VALUE"
      ;;
    SUB_PATH)
      export SUB_PATH="$PATH_VALUE"
      ;;
    SUB_JSON_PATH)
      export SUB_JSON_PATH="$PATH_VALUE"
      ;;
  esac
}

choise_dns () {
  while true; do
    hint " $(text 31) \n" && reading " $(text 1) " CHOISE_DNS
    case $CHOISE_DNS in 
      1)
        info " $(text 32) "
        tilda "$(text 10)"
        break
        ;;
      2)
        info " $(text 25) "
        tilda "$(text 10)"
        validate_path ADGUARDPATH
        echo
        break
        ;;
      *)
        info " $(text 33) "
        ;;
    esac
  done
}

### Ввод данных ###
data_entry() {
  tilda "$(text 10)"
  reading " $(text 11) " USERNAME
  echo
  reading " $(text 12) " PASSWORD
  tilda "$(text 10)"
  check_cf_token
  tilda "$(text 10)"
  reading " $(text 70) " SECRET_PASSWORD
  tilda "$(text 10)"
  reading " $(text 19) " REALITY
  tilda "$(text 10)"
  validate_path "CDNGRPC"
  echo
  validate_path "CDNSPLIT"
  echo
  validate_path "CDNHTTPU"
  echo
  validate_path "CDNWS"
  echo
  validate_path "METRICS"
  tilda "$(text 10)"
  choise_dns
  validate_path WEB_BASE_PATH
  echo
  validate_path SUB_PATH
  echo
  validate_path SUB_JSON_PATH
  tilda "$(text 10)"
  reading " $(text 67) " ENABLE_BOT_CHOISE
  case "${ENABLE_BOT_CHOISE,,}" in
    y|"")  
      reading " $(text 35) " ADMIN_ID
      echo
      reading " $(text 34) " BOT_TOKEN
      ;;
    *)
      ;;
  esac
  tilda "$(text 10)"

  SUB_URI=https://${DOMAIN}/${SUB_PATH}/
  SUB_JSON_URI=https://${DOMAIN}/${SUB_JSON_PATH}/
}

install1() {
case "$SYSTEM" in
    Debian )
      local DEBIAN_VERSION=$(echo $SYS | sed "s/[^0-9.]//g" | cut -d. -f1)
      if [ "$DEBIAN_VERSION" = '9' ]; then
        echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
        echo -e "Package: *\nPin: release a=unstable\nPin-Priority: 150\n" > /etc/apt/preferences.d/limit-unstable
      elif
        [ "$DEBIAN_VERSION" = '10' ]; then
        echo 'deb http://archive.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/backports.list
      else
        echo "deb http://deb.debian.org/debian $(awk -F '=' '/VERSION_CODENAME/{print $2}' /etc/os-release)-backports main" > /etc/apt/sources.list.d/backports.list
      fi

      ${PACKAGE_UPDATE[int]}
      ${PACKAGE_INSTALL[int]} --no-install-recommends net-tools openresolv dnsutils iptables
      ;;

    Ubuntu )
      ${PACKAGE_UPDATE[int]}
      ${PACKAGE_INSTALL[int]} --no-install-recommends net-tools openresolv dnsutils iptables
      ;;

    CentOS|Fedora)
      [ "$SYSTEM" = 'CentOS' ] && ${PACKAGE_INSTALL[int]} epel-release
      ${PACKAGE_INSTALL[int]} net-tools iptables
      ${PACKAGE_UPDATE[int]}
      ;;
  esac
}

### Обновление системы и установка пакетов ###
installation_of_utilities() {
  info " $(text 36) "
  bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/other/make_nginx.sh)
  
  apt-get update && apt-get upgrade -y && apt-get install -y \
    jq \
    ufw \
    zip \
    wget \
    sudo \
    curl \
    screen \
    gnupg2 \
    sqlite3 \
    certbot \
    net-tools \
	  lsb-release \
    apache2-utils \
  	ca-certificates \
    unattended-upgrades \
    software-properties-common \
    python3-certbot-dns-cloudflare \
    systemd-resolved

  tilda "$(text 10)"
}

# systemd-resolved
dns_systemd_resolved() {
  tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=1.1.1.1 8.8.8.8 8.8.4.4
#FallbackDNS=
Domains=~.
DNSSEC=yes
DNSOverTLS=yes
EOF
  systemctl restart systemd-resolved.service
}

dns_adguard_home() {
  rm -rf AdGuardHome_*
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz; do
    warning " $(text 38) "
    sleep 3
  done
  tar xvf AdGuardHome_linux_amd64.tar.gz

  AdGuardHome/AdGuardHome -s install
  HASH=$(htpasswd -B -C 10 -n -b ${USERNAME} ${PASSWORD} | cut -d ":" -f 2)

  rm -f AdGuardHome/AdGuardHome.yaml
  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/adh/AdGuardHome.yaml" -O AdGuardHome/AdGuardHome.yaml; do
    warning " $(text 38) "
    sleep 3
  done

  sed -i \
    -e "s/\${USERNAME}/username/g" \
    -e "s/\${HASH}/hash/g" \
    AdGuardHome/AdGuardHome.yaml

  AdGuardHome/AdGuardHome -s restart
}

dns_systemd_resolved_for_adguard() {
  tee /etc/systemd/resolved.conf <<EOF
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

### DoH, DoT ###
dns_encryption() {
  info " $(text 37) "
  dns_systemd_resolved
  case $CHOISE_DNS in
    1)
      COMMENT_AGH=""
      tilda "$(text 10)"
      ;;
    2)
      COMMENT_AGH="location /${ADGUARDPATH}/ {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;
    proxy_redirect /login.html /${ADGUARDPATH}/login.html;
    proxy_pass http://127.0.0.1:8081/;
    break;
  }"
      dns_adguard_home
      dns_systemd_resolved_for_adguard
      tilda "$(text 10)"
      ;;
    *)

      warning " $(text 33)"
      dns_encryption
      ;;
  esac
}

### Добавление пользователя ###
add_user() {
  info " $(text 39) "
  useradd -m -s $(which bash) -G sudo ${USERNAME}
  echo "${USERNAME}:${PASSWORD}" | chpasswd
  mkdir -p /home/${USERNAME}/.ssh/
  touch /home/${USERNAME}/.ssh/authorized_keys
  chown ${USERNAME}: /home/${USERNAME}/.ssh
  chmod 700 /home/${USERNAME}/.ssh
  chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh/authorized_keys
  echo ${USERNAME}
  tilda "$(text 10)"
}

### Безопасность ###
unattended_upgrade() {
  info " $(text 40) "
  echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
  echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
  dpkg-reconfigure -f noninteractive unattended-upgrades
  systemctl restart unattended-upgrades
  tilda "$(text 10)"
}

### BBR ###
enable_bbr() {
  info " $(text 41) "
  if [[ ! "$(sysctl net.core.default_qdisc)" == *"= fq" ]]; then
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
  fi

  if [[ ! "$(sysctl net.ipv4.tcp_congestion_control)" == *"bbr" ]]; then
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
  fi
}

### Отключение IPv6 ###
disable_ipv6() {
  info " $(text 42) "
  interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')
  if [[ ! "$(sysctl net.ipv6.conf.all.disable_ipv6)" == *"= 1" ]]; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  
  if [[ ! "$(sysctl net.ipv6.conf.default.disable_ipv6)" == *"= 1" ]]; then
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if [[ ! "$(sysctl net.ipv6.conf.lo.disable_ipv6)" == *"= 1" ]]; then
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi

  if [[ ! "$(sysctl net.ipv6.conf.$interface_name.disable_ipv6)" == *"= 1" ]]; then
    echo "net.ipv6.conf.$interface_name.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  sysctl -p
  tilda "$(text 10)"
}

### WARP ###
warp() {
  info " $(text 43) "
  bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/warp/xui-rp-warp.sh)
  tilda "$(text 10)"
}

### СЕРТИФИКАТЫ ###
issuance_of_certificates() {
  info " $(text 44) "
  touch cloudflare.credentials
  CF_CREDENTIALS_PATH="/root/cloudflare.credentials"
  chown root:root cloudflare.credentials
  chmod 600 cloudflare.credentials

  if [[ "$CFTOKEN" =~ [A-Z] ]]; then
    echo "dns_cloudflare_api_token = ${CFTOKEN}" >> ${CF_CREDENTIALS_PATH}
  else
    echo "dns_cloudflare_email = ${EMAIL}" >> ${CF_CREDENTIALS_PATH}
    echo "dns_cloudflare_api_key = ${CFTOKEN}" >> ${CF_CREDENTIALS_PATH}
  fi

  attempt=0
  max_attempts=2
  while [ $attempt -lt $max_attempts ]; do
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials ${CF_CREDENTIALS_PATH} --dns-cloudflare-propagation-seconds 30 --rsa-key-size 4096 -d ${DOMAIN},*.${DOMAIN} --agree-tos -m ${EMAIL} --no-eff-email --non-interactive
    
	if [ $? -eq 0 ]; then
      break
    else
      attempt=$((attempt + 1))
      sleep 5
    fi
  done

  { crontab -l; echo "0 5 1 */2 * certbot -q renew"; } | crontab -

  nginx_or_haproxy=1
  if [[ "${nginx_or_haproxy}" == "1" ]]; then
    echo "renew_hook = systemctl reload nginx" >> /etc/letsencrypt/renewal/${DOMAIN}.conf
    echo ""
    openssl dhparam -out /etc/nginx/dhparam.pem 2048
  else
    echo "renew_hook = cat /etc/letsencrypt/live/${DOMAIN}/fullchain.pem /etc/letsencrypt/live/${DOMAIN}/privkey.pem > /etc/haproxy/certs/${DOMAIN}.pem && systemctl restart haproxy" >> /etc/letsencrypt/renewal/${DOMAIN}.conf
    echo ""
    openssl dhparam -out /etc/haproxy/dhparam.pem 2048
  fi
  
  tilda "$(text 10)"
}

monitoring() {
  info " $(text 66) "
  bash <(curl -Ls https://github.com/cortez24rus/grafana-prometheus/raw/refs/heads/main/prometheus_node_exporter.sh)
  tilda "$(text 10)"
}

### NGINX ###
nginx_setup() {
  info " $(text 45) "
  mkdir -p /etc/nginx/stream-enabled/
  mkdir -p /etc/nginx/conf.d/
  rm -rf /etc/nginx/conf.d/default.conf
  touch /etc/nginx/.htpasswd
  htpasswd -nb "$USERNAME" "$PASSWORD" > /etc/nginx/.htpasswd

  nginx_conf
  stream_conf
  local_conf
  random_site

  sudo systemctl restart nginx
  nginx -s reload
  tilda "$(text 10)"
}

nginx_conf() {
  cat > /etc/nginx/nginx.conf <<EOF
user                                   www-data;
pid                                    /run/nginx.pid;
worker_processes                       auto;
worker_rlimit_nofile                   65535;
error_log                              /var/log/nginx/error.log;
include                                /etc/nginx/modules-enabled/*.conf;
events {
  multi_accept                         on;
  worker_connections                   1024;
}

http {
  map \$request_uri \$cleaned_request_uri {
    default \$request_uri;
    "~^(.*?)(\?x_padding=[^ ]*)\$" \$1;
  }
  log_format json_analytics escape=json '{'
    '\$time_local, '
    '\$http_x_forwarded_for, '
    '\$proxy_protocol_addr, '
    '\$request_method '
    '\$status, '
    '\$http_user_agent, '
    '\$cleaned_request_uri, '
    '\$http_referer, '
    '}';
  set_real_ip_from                     127.0.0.1;
  real_ip_header                       X-Forwarded-For;
  real_ip_recursive                    on;
  access_log                           /var/log/nginx/access.log json_analytics;
  sendfile                             on;
  tcp_nopush                           on;
  tcp_nodelay                          on;
  server_tokens                        off;
  log_not_found                        off; 
  types_hash_max_size                  2048;
  types_hash_bucket_size               64;
  client_max_body_size                 16M;
  keepalive_timeout                    75s;
  keepalive_requests                   1000;
  reset_timedout_connection            on;
  include                              /etc/nginx/mime.types;
  default_type                         application/octet-stream;
  ssl_session_timeout                  1d;
  ssl_session_cache                    shared:SSL:1m;
  ssl_session_tickets                  off;
  ssl_prefer_server_ciphers            on;
  ssl_protocols                        TLSv1.2 TLSv1.3;
  ssl_ciphers                          TLS13_AES_128_GCM_SHA256:TLS13_AES_256_GCM_SHA384:TLS13_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305;
  ssl_stapling                         on;
  ssl_stapling_verify                  on;
  resolver                             127.0.0.1 valid=60s;
  resolver_timeout                     2s;
  gzip                                 on;
  add_header X-XSS-Protection          "0" always;
  add_header X-Content-Type-Options    "nosniff" always;
  add_header Referrer-Policy           "no-referrer-when-downgrade" always;
  add_header Permissions-Policy        "interest-cohort=()" always;
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
  add_header X-Frame-Options           "SAMEORIGIN";
  proxy_hide_header                    X-Powered-By;
  include                              /etc/nginx/conf.d/*.conf;
}
stream {
  include /etc/nginx/stream-enabled/stream.conf;
}
EOF
}

stream_conf() {
  cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_server_name \$backend {
  ${DOMAIN}                            web;
  www.${DOMAIN}                        xtls;
  ${REALITY}                           reality;
  default                              block;
}
upstream block {
  server 127.0.0.1:36076;
}
upstream web {
  server 127.0.0.1:7443;
}
upstream reality {
  server 127.0.0.1:8443;
}
upstream xtls {
  server 127.0.0.1:9443;
}
server {
  listen 443                           reuseport;
  ssl_preread                          on;
  proxy_protocol                       on;
  proxy_pass                           \$backend;
}
EOF
}

local_conf() {
  cat > /etc/nginx/conf.d/local.conf <<EOF
server {
  listen                               80;
  server_name                          ${DOMAIN} www.${DOMAIN};
  location / {
    return 301                         https://${DOMAIN}\$request_uri;
  }
}
server {
  listen                               9090 default_server;
  server_name                          ${DOMAIN} www.${DOMAIN};
  location / {
    return 301                         https://${DOMAIN}\$request_uri;
  }
}
server {
  listen                               36076 ssl proxy_protocol;
  ssl_reject_handshake                 on;
}
server {
  listen                               36077 ssl proxy_protocol;
  http2                                on;
  server_name                          ${DOMAIN} www.${DOMAIN};

  # SSL
  ssl_certificate                      /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
  ssl_certificate_key                  /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
  ssl_trusted_certificate              /etc/letsencrypt/live/${DOMAIN}/chain.pem;

  # Diffie-Hellman parameter for DHE ciphersuites
  ssl_dhparam                          /etc/nginx/dhparam.pem;

  index index.html index.htm index.php index.nginx-debian.html;
  root /var/www/html/;

  if (\$host !~* ^(.+\.)?${DOMAIN}\$ ){return 444;}
  if (\$scheme ~* https) {set \$safe 1;}
  if (\$ssl_server_name !~* ^(.+\.)?${DOMAIN}\$ ) {set \$safe "\${safe}0"; }
  if (\$safe = 10){return 444;}
  if (\$request_uri ~ "(\"|'|\`|~|,|:|--|;|%|\\$|&&|\?\?|0x00|0X00|\||\\|\{|\}|\[|\]|<|>|\.\.\.|\.\.\/|\/\/\/)"){set \$hack 1;}
  error_page 400 401 402 403 500 501 502 503 504 =404 /404;
  proxy_intercept_errors on;

  if (\$host = ${IP4}) {
    return 444;
  }
  location /${METRICS} {
    auth_basic "Restricted Content";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:9100/metrics;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
  location /${WEB_BASE_PATH} {
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Range \$http_range;
    proxy_set_header If-Range \$http_if_range;
    proxy_pass http://127.0.0.1:36075/${WEB_BASE_PATH};
    break;
  }
  location /${SUB_PATH} {
    if (\$hack = 1) {return 404;}
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:36074/${SUB_PATH};
    break;
  }
  location /${SUB_JSON_PATH} {
    if (\$hack = 1) {return 404;}
    proxy_redirect off;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_pass http://127.0.0.1:36074/${SUB_JSON_PATH};
    break;
  }
  location /${CDNSPLIT} {
    proxy_pass http://127.0.0.1:2063;
    proxy_http_version 1.1;
    proxy_redirect off;
  }
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
    proxy_pass http://127.0.0.1:\$fwdport\$is_args\$args;
    break;
  }
  # Adguard home
  ${COMMENT_AGH}
}
EOF
}

random_site() {
  bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-random-site.sh)
}

generate_keys() {
  # Генерация пары ключей X25519 с использованием xray
  local KEY_PAIR=$(/usr/local/x-ui/bin/xray-linux-amd64 x25519)
  local PRIVATE_KEY=$(echo "$KEY_PAIR" | grep "Private key:" | awk '{print $3}')
  local PUBLIC_KEY=$(echo "$KEY_PAIR" | grep "Public key:" | awk '{print $3}')

  # Возвращаем ключи в виде строки, разделенной пробелом
  echo "$PRIVATE_KEY $PUBLIC_KEY"
}

settings_grpc() {
  STREAM_SETTINGS_GRPC=$(cat <<EOF
{
  "network": "grpc",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "grpcSettings": {
  "serviceName": "/2053/${CDNGRPC}",
  "authority": "${DOMAIN}",
  "multiMode": false
  }
}
EOF
  )
}

settings_split() {
  STREAM_SETTINGS_SPLIT=$(cat <<EOF
{
  "network": "splithttp",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "splithttpSettings": {
  "path": "${CDNSPLIT}",
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
  },
  "mode": "auto",
  "noGRPCHeader": false
  }
}
EOF
  )
}

settings_httpu() {
  STREAM_SETTINGS_HTTPU=$(cat <<EOF
{
  "network": "httpupgrade",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "httpupgradeSettings": {
  "acceptProxyProtocol": false,
  "path": "/2073/${CDNHTTPU}",
  "host": "${DOMAIN}",
  "headers": {}
  }
}
EOF
  )
}

settings_ws() {
  STREAM_SETTINGS_WS=$(cat <<EOF
{
  "network": "ws",
  "security": "none",
  "externalProxy": [
  {
    "forceTls": "tls",
    "dest": "${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "wsSettings": {
  "acceptProxyProtocol": false,
  "path": "/2083/${CDNWS}",
  "host": "${DOMAIN}",
  "headers": {}
  }
}
EOF
  )
}

settings_steal() {
  read PRIVATE_KEY0 PUBLIC_KEY0 <<< "$(generate_keys)"
  STREAM_SETTINGS_STEAL=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "www.${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "realitySettings": {
  "show": false,
  "xver": 2,
  "dest": "36077",
  "serverNames": [
    "${DOMAIN}"
  ],
  "privateKey": "${PRIVATE_KEY0}",
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
    "publicKey": "${PUBLIC_KEY0}",
    "fingerprint": "random",
    "serverName": "",
    "spiderX": "/"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

settings_reality() {
  read PRIVATE_KEY1 PUBLIC_KEY1 <<< "$(generate_keys)"
  STREAM_SETTINGS_REALITY=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "www.${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "realitySettings": {
  "show": false,
  "xver": 0,
  "dest": "${REALITY}:443",
  "serverNames": [
    "${REALITY}"
  ],
  "privateKey": "${PRIVATE_KEY1}",
  "minClient": "",
  "maxClient": "",
  "maxTimediff": 0,
  "shortIds": [
    "c7c487",
    "cf",
    "248c16289e",
    "ae60608a67d1a367",
    "21221b811591",
    "648bc6ab5ba1bc",
    "73d1",
    "3028618d"
  ],
  "settings": {
    "publicKey": "${PUBLIC_KEY1}",
    "fingerprint": "random",
    "serverName": "",
    "spiderX": "/"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
  "header": {
    "type": "none"
  }
  }
}
EOF
  )
}

settings_xtls() {
  STREAM_SETTINGS_XTLS=$(cat <<EOF
{
  "network": "tcp",
  "security": "tls",
  "externalProxy": [
  {
    "forceTls": "same",
    "dest": "www.${DOMAIN}",
    "port": 443,
    "remark": ""
  }
  ],
  "tlsSettings": {
  "serverName": "www.${DOMAIN}",
  "minVersion": "1.3",
  "maxVersion": "1.3",
  "cipherSuites": "",
  "rejectUnknownSni": false,
  "disableSystemRoot": false,
  "enableSessionResumption": false,
  "certificates": [
    {
    "certificateFile": "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem",
    "keyFile": "/etc/letsencrypt/live/${DOMAIN}/privkey.pem",
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
    "fingerprint": "random"
  }
  },
  "tcpSettings": {
  "acceptProxyProtocol": true,
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
UPDATE users 
SET username = '$USERNAME', password = '$PASSWORD' 
WHERE id = 1;

UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_GRPC' WHERE LOWER(remark) LIKE '%grpc%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_SPLIT' WHERE LOWER(remark) LIKE '%split%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_HTTPU' WHERE LOWER(remark) LIKE '%httpu%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_WS' WHERE LOWER(remark) LIKE '%ws%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_STEAL' WHERE LOWER(remark) LIKE '%steal%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_REALITY' WHERE LOWER(remark) LIKE '%whatsapp%';
UPDATE inbounds SET stream_settings = '$STREAM_SETTINGS_XTLS' WHERE LOWER(remark) LIKE '%xtls%';

UPDATE settings SET value = '/${WEB_BASE_PATH}/' WHERE LOWER(key) LIKE '%webbasepath%';
UPDATE settings SET value = '/${SUB_PATH}/' WHERE LOWER(key) LIKE '%subpath%';
UPDATE settings SET value = '${SUB_URI}' WHERE LOWER(key) LIKE '%suburi%';
UPDATE settings SET value = '/${SUB_JSON_PATH}/' WHERE LOWER(key) LIKE '%subjsonpath%';
UPDATE settings SET value = '${SUB_JSON_URI}' WHERE LOWER(key) LIKE '%subjsonuri%';
EOF
}

#json_rules() {
#  SUB_JSON_RULES=$(cat <<EOF
#[{"type":"field","outboundTag":"direct","domain":["keyword:xn--","keyword:ru","keyword:su","keyword:kg","keyword:by","keyword:kz","keyword:rt","keyword:yandex","keyword:avito.","keyword:2gis.","keyword:gismeteo.","keyword:livejournal."]},{"type":"field","outboundTag":"direct","domain":["domain:ru","domain:su","domain:kg","domain:by","domain:kz"]},{"type":"field","outboundTag":"direct","domain":["geosite:category-ru","geosite:category-gov-ru","geosite:yandex","geosite:vk","geosite:whatsapp","geosite:apple","geosite:mailru","geosite:github","geosite:gitlab","geosite:duckduckgo","geosite:google","geosite:wikimedia","geosite:mozilla"]},{"type":"field","outboundTag":"direct","ip":["geoip:private","geoip:ru"]}]
#EOF
#  )
#}
#UPDATE settings SET value = '${SUB_JSON_RULES}' WHERE LOWER(key) LIKE '%subjsonrules%';


### Установка 3x-ui ###
install_panel() {
  info " $(text 46) "
  touch /usr/local/xui-rp/reinstallation_check

  while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/other/x-ui.gpg; do
    warning " $(text 38) "
    sleep 3
  done
  
  echo ${SECRET_PASSWORD} | gpg --batch --yes --passphrase-fd 0 -d x-ui.gpg > x-ui.db
  echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) > /dev/null 2>&1

  settings_grpc
  settings_split
  settings_httpu
  settings_ws
  settings_steal
  settings_reality
  settings_xtls
#  json_rules
  database_change

  x-ui stop
  
  rm -rf x-ui.gpg
  rm -rf /etc/x-ui/x-ui.db.backup
  [ -f /etc/x-ui/x-ui.db ] && mv /etc/x-ui/x-ui.db /etc/x-ui/x-ui.db.backup
  mv x-ui.db /etc/x-ui/
  
  x-ui start
  echo -e "20\n1" | x-ui > /dev/null 2>&1
  tilda "$(text 10)"
}

### UFW ###
enabling_security() {
  info " $(text 47) "
  ufw --force reset
  ufw allow 36079/tcp
  ufw allow 443/tcp
  ufw allow 22/tcp
  ufw insert 1 deny from $(echo ${IP4} | cut -d '.' -f 1-3).0/22
  ufw --force enable
  tilda "$(text 10)"
}

### SSH ####
ssh_setup() {
  exec > /dev/tty 2>&1
  info " $(text 48) "
  out_data " $(text 49) "
  echo
  out_data " $(text 50) "
  out_data " $(text 51) "
  echo
  out_data " $(text 52)" "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${USERNAME}@${IP4} \"cat >> ~/.ssh/authorized_keys\""
  out_data " $(text 53)" "ssh-copy-id -p 22 ${USERNAME}@${IP4}"
  echo
  while read -r -t 0.1 -n 1; do :; done
  reading " $(text 54) " ANSWER_SSH
  if [[ "${ANSWER_SSH}" == [yY] ]]; then
    # Цикл проверки наличия ключа
    while true; do
      if [[ -n $(grep -v '^[[:space:]]*$' "/home/${USERNAME}/.ssh/authorized_keys") || -n $(grep -v '^[[:space:]]*$' "/root/.ssh/authorized_keys") ]]; then
        info " $(text 56) "
        break
      else
        warning " $(text 55) "
        echo
        reading " $(text 54) " CONTINUE_SSH
        if [[ "${CONTINUE_SSH}" != [yY] ]]; then
          warning " $(text 9) " # Настройка отменена
          return 0
        fi
      fi
    done
    # Если ключ найден, продолжаем настройку SSH
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

    # Настройка баннера
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
       | █████ █████ ███████████   █████████   █████ █████|
       |░░███ ░░███ ░░███░░░░░███   ███░░░░░███ ░░███ ░░███ |
       | ░░███ ███   ░███  ░███  ░███  ░███  ░░███ ███  |
       |  ░░█████  ░██████████   ░███████████   ░░█████   |
       |   ███░███   ░███░░░░░███  ░███░░░░░███  ░░███  |
       |  ███ ░░███  ░███  ░███  ░███  ░███   ░███  |
       | █████ █████ █████   █████ █████   █████  █████   |
       |░░░░░ ░░░░░ ░░░░░   ░░░░░ ░░░░░   ░░░░░  ░░░░░  |
       +----------------------------------------------------+


EOF
    systemctl restart ssh.service
  else
    warning " $(text 9) "
    return 0
  fi
}

# Установока xui бота
install_bot() {
  case "${ENABLE_BOT_CHOISE,,}" in
    y|"")  
      info " $(text 57) "
      bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install-bot.sh) "$BOT_TOKEN" "$ADMIN_ID" "$DOMAIN"
      ;;
    *)
      ;;
  esac
}

### Окончание ###
data_output() {
  tilda "$(text 10)"
  info " $(text 58) "
  printf '0\n' | x-ui | grep --color=never -i ':'
  echo
  out_data " $(text 59) " "https://${DOMAIN}/${WEB_BASE_PATH}/"
  out_data " $(text 60) " "${SUB_URI}user"
  if [[ $CHOISE_DNS = "2" ]]; then
    out_data " $(text 61) " "https://${DOMAIN}/${ADGUARDPATH}/login.html"
    
  fi
  echo
  out_data " $(text 62) " "ssh -p 36079 ${USERNAME}@${IP4}"
  echo
  out_data " $(text 63) " "$USERNAME"
  out_data " $(text 64) " "$PASSWORD"
  echo
  out_data " $(text 65) " "$LOGFILE"
  tilda "$(text 10)"
}

# Удаление всех управляющих последовательностей
log_clear() {
  sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$LOGFILE"
}

main() {
  log_entry
  read_defaults_from_file
  parse_args "$@" || show_help
  echo "NGINX: ${args[nginx]}"
  echo "Panel: ${args[panel]}"
  check_root
  check_ip
  check_operating_system
  select_language
  if [ -f ${defaults_file} ]; then
    tilda "$(text 4)"
  fi
  sleep 2
  clear
  banner_1
  start_installation
  data_entry
  [[ ${args[utils]} == "true" ]] && installation_of_utilities
  [[ ${args[dns]} == "true" ]] && dns_encryption
  [[ ${args[addu]} == "true" ]] && add_user
  [[ ${args[autoupd]} == "true" ]] && unattended_upgrade
  [[ ${args[bbr]} == "true" ]] && enable_bbr
  [[ ${args[ipv6]} == "true" ]] && disable_ipv6
  [[ ${args[warp]} == "true" ]] && warp
  [[ ${args[cert]} == "true" ]] && issuance_of_certificates
  [[ ${args[mon]} == "true" ]] && monitoring
  write_defaults_to_file
  [[ ${args[nginx]} == "true" ]] && nginx_setup
  [[ ${args[panel]} == "true" ]] && install_panel
  [[ ${args[ufw]} == "true" ]] && enabling_security
  [[ ${args[ssh]} == "true" ]] && ssh_setup
  [[ ${args[tgbot]} == "true" ]] && install_bot
  data_output
  banner_1
  log_clear
}

main "$@"
