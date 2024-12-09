#!/usr/bin/env bash
# wget -N https://git && bash .sh d
export DEBIAN_FRONTEND=noninteractive

declare -A defaults
declare -A args
declare -A regex

regex[domain]="^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+\.[a-zA-Z]{2,})$"
regex[port]="^[1-9][0-9]*$"
regex[warp_license]="^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{8}-[a-zA-Z0-9]{8}$"
regex[username]="^[a-zA-Z0-9]+$"
regex[ip]="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
regex[tgbot_token]="^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$"
regex[tgbot_admins]="^[a-zA-Z][a-zA-Z0-9_]{4,31}(,[a-zA-Z][a-zA-Z0-9_]{4,31})*$"
regex[domain_port]="^[a-zA-Z0-9]+([-.][a-zA-Z0-9]+)*\.[a-zA-Z]{2,}(:[1-9][0-9]*)?$"
regex[file_path]="^[a-zA-Z0-9_/.-]+$"
regex[url]="^(http|https)://([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(:[0-9]{1,5})?(/.*)?$"

defaults_file="/usr/local/xui-rp/reinstall_defaults.conf"

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
E[13]="Enter the domain (with or without a subdomain):"
R[13]="Введите домен (с поддоменом или без):"
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
E[75]="Invalid option for --$key: $value. Use 'true' or 'false'."
R[75]="Неверная опция для --$key: $value. Используйте 'true' или 'false'."
E[76]="Unknown option: $1"
R[76]="Неверная опция: $1"
E[77]=""
R[77]="Список зависимостей для установки:"
E[78]=""
R[78]="Все зависимости уже установлены и не требуют дополнительной установки."
E[79]=""
R[79]="Настройка шаблона сайта."
E[80]="Random template name:"
R[80]="Случайное имя шаблона:"
E[81]=""
R[81]=""
E[82]=""
R[82]=""
E[83]=""
R[83]=""
E[84]=""
R[84]=""
E[85]=""
R[85]=""
E[86]=""
R[86]=""
E[87]=""
R[87]=""
E[88]=""
R[88]=""
E[89]=""
R[89]=""
E[90]=""
R[90]=""
E[91]=""
R[91]=""
E[92]=""
R[92]=""
E[93]=""
R[93]=""
E[94]=""
R[94]=""
E[95]=""
R[95]=""
E[96]=""
R[96]=""
E[97]=""
R[97]=""
E[98]=""
R[98]=""
E[99]=""
R[99]=""
E[100]="  -u, --utils <true|false>       Additional utilities (default: ${defaults[utils]})"
R[100]="  -u, --utils <true|false>       Дополнительные утилиты (по умолчанию: ${defaults[utils]})"
E[101]="  -d, --dns <true|false>         DNS encryption (default: ${defaults[dns]})"
R[101]="  -d, --dns <true|false>         Шифрование DNS (по умолчанию: ${defaults[dns]})"
E[102]="  -a, --addu <true|false>        User addition (default: ${defaults[addu]})"
R[102]="  -a, --addu <true|false>        Добавление пользователя (по умолчанию: ${defaults[addu]})"
E[103]="  -r, --autoupd <true|false>     Automatic updates (default: ${defaults[autoupd]})"
R[103]="  -r, --autoupd <true|false>     Автоматические обновления (по умолчанию: ${defaults[autoupd]})"
E[104]="  -b, --bbr <true|false>         BBR (TCP Congestion Control) (default: ${defaults[bbr]})"
R[104]="  -b, --bbr <true|false>         BBR (управление перегрузкой TCP) (по умолчанию: ${defaults[bbr]})"
E[105]="  -i, --ipv6 <true|false>        Disable IPv6 support (default: ${defaults[ipv6]})"
R[105]="  -i, --ipv6 <true|false>        Отключить поддержку IPv6 (по умолчанию: ${defaults[ipv6]})"
E[106]="  -w, --warp <true|false>        Warp (default: ${defaults[warp]})"
R[106]="  -w, --warp <true|false>        Warp (по умолчанию: ${defaults[warp]})"
E[107]="  -c, --cert <true|false>        Certificate issuance for domain (default: ${defaults[cert]})"
R[107]="  -c, --cert <true|false>        Выпуск сертификатов для домена (по умолчанию: ${defaults[cert]})"
E[108]="  -m, --mon <true|false>         Monitoring services (e.g., node_exporter) (default: ${defaults[mon]})"
R[108]="  -m, --mon <true|false>         Сервисы мониторинга (например, node_exporter) (по умолчанию: ${defaults[mon]})"
E[109]="  -n, --nginx <true|false>       NGINX installation (default: ${defaults[nginx]})"
R[109]="  -n, --nginx <true|false>       Установка NGINX (по умолчанию: ${defaults[nginx]})"
E[110]="  -p, --panel <true|false>       Panel installation for user management (default: ${defaults[panel]})"
R[110]="  -p, --panel <true|false>       Установка панели для управления пользователями (по умолчанию: ${defaults[panel]})"
E[111]="  -f, --firewall <true|false>    Firewall configuration (default: ${defaults[ufw]})"
R[111]="  -f, --firewall <true|false>    Настройка файрвола (по умолчанию: ${defaults[ufw]})"
E[112]="  -s, --ssh <true|false>         SSH access (default: ${defaults[ssh]})"
R[112]="  -s, --ssh <true|false>         SSH доступ (по умолчанию: ${defaults[ssh]})"
E[113]="  -t, --tgbot <true|false>       Telegram bot integration for user management (default: ${defaults[tgbot]})"
R[113]="  -t, --tgbot <true|false>       Интеграция Telegram бота для управления пользователями (по умолчанию: ${defaults[tgbot]})"
E[114]="  -h, --help                     Display this help message"
R[114]="  -h, --help                     Показать это сообщение помощи"

# Функция для отображения справки
show_help() {
  echo
  info "Usage: xui-rp-install-server.sh [-u|--utils <true|false>] [-d|--dns <true|false>] [-a|--addu <true|false>]"
  info "       [-r|--autoupd <true|false>] [-b|--bbr <true|false>] [-i|--ipv6 <true|false>] [-w|--warp <true|false>]"
  info "       [-c|--cert <true|false>] [-m|--mon <true|false>] [-n|--nginx <true|false>] [-p|--panel <true|false>]"
  info "       [-f|--firewall <true|false>] [-s|--ssh <true|false>] [-t|--tgbot <true|false>] [-h|--help]"
  echo
  info " $(text 100) "
  info " $(text 101) "
  info " $(text 102) "
  info " $(text 103) "
  info " $(text 104) "
  info " $(text 105) "
  info " $(text 106) "
  info " $(text 107) "
  info " $(text 108) "
  info " $(text 109) "
  info " $(text 110) "
  info " $(text 111) "
  info " $(text 112) "
  info " $(text 113) "
  info " $(text 114) "
  echo
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
defaults[ssh]=false
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
      warning " $(text 75) "
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
        warning " $(text 76) "
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
  MAJOR=("10" "20" "7")
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
}

check_dependencies() {
  # Зависимости, необходимые для трех основных систем
  [ "${SYSTEM}" = 'CentOS' ] && ${PACKAGE_INSTALL[int]} vim-common epel-release
  DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip" "sudo")
  DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2" "sudo")

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

### Проверка рута ###
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error " $(text 8) "
  fi
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
    local temp_domain
    local DOMAIN
    local SUBDOMAIN

    while [[ -z "$temp_domain" ]]; do
        reading " $(text 13) " temp_domain
        echo
    done

    # Удаляем http:// или https:// (если они есть), порты и пути
    temp_domain=$(echo "$temp_domain" | sed -E 's/^https?:\/\///' | sed -E 's/(:[0-9]+)?(\/[a-zA-Z0-9_\-\/]+)?$//')

    # Проверка на наличие домена третьего уровня (например, grf.x.com)
    if [[ "$temp_domain" =~ ${regex[domain]} ]]; then
      SUBDOMAIN="$temp_domain"           # Весь домен сохраняем в SUBDOMAIN
      DOMAIN="${BASH_REMATCH[2]}"        # Извлекаем домен второго уровня (x.com)
    else
      DOMAIN="$temp_domain"              # Если это домен второго уровня, то просто сохраняем
      SUBDOMAIN="www.$temp_domain"       # Для домена второго уровня подставляем www в SUBDOMAIN
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
      error " $(text 29) "
      echo
    elif [[ $PATH_VALUE =~ ['{}\$/\\'] ]]; then
      error " $(text 30) "
      echo
    else
      break
    fi
  done
  
  # Экранируем пробелы в пути
  local ESCAPED_PATH=$(echo "$PATH_VALUE" | sed 's/ /\\ /g')

  # Присваиваем значение переменной
  case "$VARIABLE_NAME" in
    CDNGRPC)
      export CDNGRPC="$ESCAPED_PATH"
      ;;
    CDNSPLIT)
      export CDNSPLIT="$ESCAPED_PATH"
      ;;
    CDNHTTPU)
      export CDNHTTPU="$ESCAPED_PATH"
      ;;
    CDNWS)
      export CDNWS="$ESCAPED_PATH"
      ;;
    METRICS)
      export METRICS="$ESCAPED_PATH"
      ;;
    ADGUARDPATH)
      export ADGUARDPATH="$ESCAPED_PATH"
      ;;
    WEB_BASE_PATH)
      export WEB_BASE_PATH="$ESCAPED_PATH"
      ;;
    SUB_PATH)
      export SUB_PATH="$ESCAPED_PATH"
      ;;
    SUB_JSON_PATH)
      export SUB_JSON_PATH="$ESCAPED_PATH"
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
  reading " $(text 70) " SECRET_PASSWORD

  tilda "$(text 10)"

  reading " $(text 11) " USERNAME
  echo
  reading " $(text 12) " PASSWORD
  [[ ${args[addu]} == "true" ]] && add_user
  
  tilda "$(text 10)"

  check_cf_token
  
  tilda "$(text 10)"

  reading " $(text 19) " REALITY
  echo
  validate_path "CDNGRPC"
  echo
  validate_path "CDNSPLIT"
  echo
  validate_path "CDNHTTPU"
  echo
  validate_path "CDNWS"
  if [[ ${args[mon]} == "true" ]]; then
    echo
    validate_path "METRICS"
  fi

  tilda "$(text 10)"

  choise_dns

  validate_path WEB_BASE_PATH
  echo
  validate_path SUB_PATH
  echo
  validate_path SUB_JSON_PATH

  tilda "$(text 10)"

  if [[ ${args[ssh]} == "true" ]]; then
    reading " $(text 54) " ANSWER_SSH
    if [[ "${ANSWER_SSH,,}" == "y" ]]; then
      info " $(text 48) "
      out_data " $(text 49) "
      echo
      out_data " $(text 50) "
      out_data " $(text 51) "
      echo
      out_data " $(text 52)" "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${USERNAME}@${IP4} \"cat >> ~/.ssh/authorized_keys\""
      out_data " $(text 53)" "ssh-copy-id -p 22 ${USERNAME}@${IP4}"
      echo

      # Цикл проверки наличия ключей
      while true; do
        if [[ -s "/home/${USERNAME}/.ssh/authorized_keys" || -s "/root/.ssh/authorized_keys" ]]; then
          info " $(text 56) " # Ключи найдены
          SSH_OK=true
          break
        else
          warning " $(text 55) " # Ключи отсутствуют
          echo
          reading " $(text 54) " ANSWER_SSH
          if [[ "${ANSWER_SSH,,}" != "y" ]]; then
            warning " $(text 9) " # Настройка отменена
            SSH_OK=false
            break
          fi
        fi
      done
      tilda "$(text 10)"
    else
      warning " $(text 9) " # Настройка пропущена
      SSH_OK=false
    fi
  fi

  if [[ ${args[tgbot]} == "true" ]]; then
    reading " $(text 35) " ADMIN_ID
    echo
    reading " $(text 34) " BOT_TOKEN
    tilda "$(text 10)"
  fi

  SUB_URI=https://${DOMAIN}/${SUB_PATH}/
  SUB_JSON_URI=https://${DOMAIN}/${SUB_JSON_PATH}/
}

nginx_make() {
  case "$SYSTEM" in
    Debian|Ubuntu)
      DEPS_BUILD_CHECK=("git" "gcc" "make" "libpcre2-dev" "libssl-dev" "libgeoip-dev" "libxslt1-dev" "zlib1g-dev" "libgd-dev" "libmaxminddb0" "libmaxminddb-dev" "mmdb-bin")
      DEPS_BUILD_INSTALL=("git" "build-essential" "libpcre2-dev" "libssl-dev" "libgeoip-dev" "libxslt1-dev" "zlib1g-dev" "libgd-dev" "libmaxminddb0" "libmaxminddb-dev" "mmdb-bin")
    
      for g in "${!DEPS_BUILD_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_BUILD_CHECK[g]})" ] && [[ ! "${DEPS_BUILD[@]}" =~ "${DEPS_BUILD_INSTALL[g]}" ]] && DEPS_BUILD+=(${DEPS_BUILD_INSTALL[g]})
      done
    
      if [ "${#DEPS_BUILD[@]}" -ge 1 ]; then
        echo "Список зависимостей для установки ${DEPS_BUILD[@]}"
        ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
        ${PACKAGE_INSTALL[int]} ${DEPS_BUILD[@]} >/dev/null 2>&1
      else
        echo "Все зависимости уже установлены и не требуют дополнительной установки."
      fi
      ;;

    CentOS|Fedora)
      DEPS_BUILD_CHECK=("git" "gcc" "make" "pcre-devel" "openssl-devel" "GeoIP-devel" "libxslt-devel" "zlib-devel" "gd-devel" "libmaxminddb" "libmaxminddb-devel" "mmdblookup")
      DEPS_BUILD_INSTALL=("git" "gcc" "make" "pcre-devel" "openssl-devel" "GeoIP-devel" "libxslt-devel" "zlib-devel" "gd-devel" "libmaxminddb" "libmaxminddb-devel" "mmdb-bin")
    
      for g in "${!DEPS_BUILD_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_BUILD_CHECK[g]})" ] && [[ ! "${DEPS_BUILD[@]}" =~ "${DEPS_BUILD_INSTALL[g]}" ]] && DEPS_BUILD+=(${DEPS_BUILD_INSTALL[g]})
      done
    
      if [ "${#DEPS_BUILD[@]}" -ge 1 ]; then
        echo "Список зависимостей для установки ${DEPS_BUILD[@]}"
        ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
        ${PACKAGE_INSTALL[int]} ${DEPS_BUILD[@]} >/dev/null 2>&1
      else
        echo "Все зависимости уже установлены и не требуют дополнительной установки."
      fi
      ;;
  esac

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
  
  systemctl daemon-reload
  systemctl start nginx
  systemctl enable nginx
  systemctl restart nginx
  systemctl status nginx --no-pager
  cd ..
  rm -rf nginx-$NGINX_VERSION.tar.gz nginx-$NGINX_VERSION ngx_http_geoip2_module
}

nginx_gpg() {
  case "$SYSTEM" in
    Debian)
      ${PACKAGE_INSTALL[int]} debian-archive-keyring
      curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
      gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/debian `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list
      echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx
      ;;

    Ubuntu)
      ${PACKAGE_INSTALL[int]} ubuntu-keyring
      curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
      gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list
      echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx
      ;;

    CentOS|Fedora)
      ${PACKAGE_INSTALL[int]} yum-utils
      cat <<EOL > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOL
      ;;
  esac
  ${PACKAGE_UPDATE[int]}
  ${PACKAGE_INSTALL[int]} nginx
  systemctl daemon-reload
  systemctl start nginx
  systemctl enable nginx
  systemctl restart nginx
  systemctl status nginx --no-pager
}

installation_of_utilities() {
  info " $(text 36) "
  case "$SYSTEM" in
    Debian|Ubuntu)
      DEPS_PACK_CHECK=("jq" "ufw" "zip" "wget" "gpg" "cron" "sqlite3" "certbot" "openssl" "netstat" "htpasswd" "update-ca-certificates" "add-apt-repository" "certbot-dns-cloudflare")
      DEPS_PACK_INSTALL=("jq" "ufw" "zip" "wget" "gnupg2" "cron" "sqlite3" "certbot" "openssl" "net-tools" "apache2-utils" "ca-certificates" "software-properties-common" "python3-certbot-dns-cloudflare")

      for g in "${!DEPS_PACK_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_PACK_CHECK[g]})" ] && [[ ! "${DEPS_PACK[@]}" =~ "${DEPS_PACK_INSTALL[g]}" ]] && DEPS_PACK+=(${DEPS_PACK_INSTALL[g]})
      done

      if [ "${#DEPS_PACK[@]}" -ge 1 ]; then
        info " $(text 77) ": ${DEPS_PACK[@]}
        ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
        ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]} >/dev/null 2>&1
      else
        info " $(text 78) "
      fi
      ;;

    CentOS|Fedora)
      DEPS_PACK_CHECK=("jq" "zip" "tar" "wget" "gpg" "crontab" "sqlite3" "openssl" "netstat" "nslookup" "htpasswd" "certbot" "update-ca-certificates" "certbot-dns-cloudflare")
      DEPS_PACK_INSTALL=("jq" "zip" "tar" "wget" "gnupg2" "cronie" "sqlite" "openssl" "net-tools" "bind-utils" "httpd-tools" "certbot" "ca-certificates" "python3-certbot-dns-cloudflare")

      for g in "${!DEPS_PACK_CHECK[@]}"; do
        [ ! -x "$(type -p ${DEPS_PACK_CHECK[g]})" ] && [[ ! "${DEPS_PACK[@]}" =~ "${DEPS_PACK_INSTALL[g]}" ]] && DEPS_PACK+=(${DEPS_PACK_INSTALL[g]})
      done

      if [ "${#DEPS_PACK[@]}" -ge 1 ]; then
        info " $(text 77) ": ${DEPS_PACK[@]}
        ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
        ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]} >/dev/null 2>&1
      else
        info " $(text 78) "
      fi
      ;;
  esac

  #nginx_make
  nginx_gpg
  ${PACKAGE_INSTALL[int]} systemd-resolved
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

  case "$SYSTEM" in
    Debian|Ubuntu)
      useradd -m -s $(which bash) -G sudo ${USERNAME}
      ;;

    CentOS|Fedora)
      useradd -m -s $(which bash) -G wheel ${USERNAME}
      ;;
  esac
  echo "${USERNAME}:${PASSWORD}" | chpasswd
  mkdir -p /home/${USERNAME}/.ssh/
  touch /home/${USERNAME}/.ssh/authorized_keys
  chown -R ${USERNAME}: /home/${USERNAME}/.ssh
  chmod -R 700 /home/${USERNAME}/.ssh
  echo ${USERNAME}

  tilda "$(text 10)"
}

### Безопасность ###
setup_auto_updates() {
  info " $(text 40) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
      echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
      dpkg-reconfigure -f noninteractive unattended-upgrades
      systemctl restart unattended-upgrades
      ;;

    CentOS|Fedora)
      cat > /etc/dnf/automatic.conf <<EOF
[commands]
upgrade_type = security
random_sleep = 0
download_updates = yes
apply_updates = yes

[email]
email_from = root@localhost
email_to = root
email_host = localhost
EOF
      systemctl enable --now dnf-automatic.timer
      systemctl status dnf-automatic.timer
      ;;
  esac

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
  sysctl -p
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
  
  mkdir -p /usr/local/xui-rp/
  mkdir -p /etc/systemd/system/warp-svc.service.d
  cd /usr/local/xui-rp/

  case "$SYSTEM" in
    Debian|Ubuntu)
      while ! wget --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://pkg.cloudflareclient.com/pool/$(grep "VERSION_CODENAME=" /etc/os-release | cut -d "=" -f 2)/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb"; do
        warning " $(text 38) "
        sleep 3
      done
      apt install -y ./cloudflare-warp_2024.6.497-1_amd64.deb
      ;;

    CentOS|Fedora)
      while ! wget --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2024.6.497-1.x86_64.rpm"; do
        warning " $(text 38) "
        sleep 3
      done
      sudo yum localinstall -y cloudflare-warp-2024.6.497-1.x86_64.rpm
      ;;
  esac

  rm -rf cloudflare-warp_*
  cd ~

  cat > /etc/systemd/system/warp-svc.service.d/override.conf <<EOF
[Service]
LogLevelMax=3
EOF

  echo
  systemctl daemon-reload
  systemctl restart warp-svc.service
  sleep 3

  systemctl status warp-svc || echo "Служба warp-svc не найдена или не запустилась."

  warp-cli --accept-tos disconnect || true
  warp-cli --accept-tos registration delete || true
  script -q -c "echo y | warp-cli registration new"
  warp-cli --accept-tos mode proxy
  warp-cli --accept-tos proxy port 40000
  warp-cli --accept-tos connect

  echo
  sleep 3
  warp-cli tunnel stats

  if curl -x socks5h://localhost:40000 https://2ip.io; then
    echo "Настройка завершена: WARP подключен и работает."
  else
    echo "Ошибка: не удалось подключиться к WARP через прокси. Проверьте настройки."
  fi

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
    cat > ${CF_CREDENTIALS_PATH} <<EOF
dns_cloudflare_api_token = ${CFTOKEN}
EOF
  else
    cat > ${CF_CREDENTIALS_PATH} <<EOF
dns_cloudflare_email = ${EMAIL}
dns_cloudflare_api_key = ${CFTOKEN}
EOF
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
  
  COMMENT_METRIC="location /${METRICS} {
    auth_basic \"Restricted Content\";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://127.0.0.1:9100/metrics;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    break;
  }"
  
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

  case "$SYSTEM" in
    Debian|Ubuntu)
      usernginx="www-data"
      ;;

    CentOS|Fedora)
      usernginx="nginx"
      ;;
  esac

  nginx_conf
  stream_conf
  local_conf
  random_site

  sleep 2
  systemctl restart nginx
  sleep 2
  nginx -s reload

  tilda "$(text 10)"
}

nginx_conf() {
  cat > /etc/nginx/nginx.conf <<EOF
user                                   ${usernginx};
pid                                    /var/run/nginx.pid;
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
#server {
#  listen                               80;
#  server_name                          ${DOMAIN} www.${DOMAIN};
#  location / {
#    return 301                         https://${DOMAIN}\$request_uri;
#  }
#}
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
  ${COMMENT_METRIC}
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
  ${COMMENT_AGH}
}
EOF
}

random_site() {
  info " $(text 79) "
  mkdir -p /var/www/html/ /usr/local/xui-rp/

  cd /usr/local/xui-rp/ || { echo "Не удалось перейти в /usr/local/xui-rp/"; exit 1; }

  if [[ ! -d "simple-web-templates-main" ]]; then
      while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/simple-web-templates/archive/refs/heads/main.zip"; do
        warning " $(text 38) "
        sleep 3
      done
      unzip -q main.zip &>/dev/null && rm -f main.zip
  fi

  cd simple-web-templates-main || { echo "Не удалось перейти в папку с шаблонами"; exit 1; }

  rm -rf assets ".gitattributes" "README.md" "_config.yml"

  RandomHTML=$(ls -d */ | shuf -n1)  # Обновил для выбора случайного подкаталога
  info " $(text 80) ${RandomHTML}"

  # Если шаблон существует, копируем его в /var/www/html
  if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
      echo "Копируем шаблон в /var/www/html/..."
      rm -rf /var/www/html/*  # Очищаем старую папку
      cp -a "${RandomHTML}/." /var/www/html/ || { echo "Ошибка при копировании шаблона"; exit 1; }
  else
      echo "Ошибка при извлечении шаблона!"
      exit 1
  fi

  cd ~ || { echo "Не удалось вернуться в домашнюю директорию"; exit 1; }
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
  BLOCK_ZONE_IP=$(echo ${IP4} | cut -d '.' -f 1-3).0/22

  case "$SYSTEM" in
    Debian|Ubuntu )  
      ufw --force reset
      ufw allow 36079/tcp
      ufw allow 443/tcp
      ufw insert 1 deny from "$BLOCK_ZONE_IP"
      ufw --force enable
      ;;

    CentOS|Fedora )
      systemctl enable --now firewalld
      firewall-cmd --permanent --zone=public --add-port=36079/tcp
      firewall-cmd --permanent --zone=public --add-port=443/tcp
      firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$BLOCK_ZONE_IP' reject"
      firewall-cmd --reload
      ;;
  esac

  tilda "$(text 10)"
}

### SSH ####
ssh_setup() {
  if [[ "${ANSWER_SSH,,}" == "y" ]]; then
    info " $(text 48) "
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
    systemctl restart sshd
    tilda "$(text 10)"
  fi
}

# Установока xui бота
install_bot() {
  info " $(text 57) "
  bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install-bot.sh) "$BOT_TOKEN" "$ADMIN_ID" "$DOMAIN"
  tilda "$(text 10)"
}

### Окончание ###
data_output() {
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
  exec > /dev/tty 2>&1
}

# Удаление всех управляющих последовательностей
log_clear() {
  sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$LOGFILE"
}

main() {
  log_entry
  read_defaults_from_file
  parse_args "$@" || show_help
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
  [[ ${args[autoupd]} == "true" ]] && setup_auto_updates
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
