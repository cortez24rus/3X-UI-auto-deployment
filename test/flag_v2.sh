#!/bin/bash

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
      echo "Invalid option for --$key: $2. Use 'true' or 'false'."
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

check_root(){
  echo "Рут есть"
}
disable_ipv6(){
  echo "Отключение ipv6"
}
warp(){
  echo "Установка Warp"
}
monitoring(){
  echo "Установка Node exporter"
}
enabling_security(){
  echo "Настройка UFW"
}
ssh_setup(){
  echo "Настройка SSH"
}
install_bot(){
  echo "Установка tg бота"
}
issuance_of_certificates(){
  echo "Выдача сертификатов"
}
nginx_setup(){
  echo "Установка NGINX"
}
log_clear(){
  echo "Чистка логов"
}
installation_of_utilities(){
  echo "Установка утилит"
}
dns_encryption(){
  echo "Шифрование DNS"
}
add_user(){
  echo "Добавление пользователя"
}
unattended_upgrade(){
  echo "Автоматические обновления"
}
enable_bbr(){
  echo "Включение BBR"
}
check_operating_system(){
  echo "Проверка операционной системы"
}
select_language(){
  echo "Выбор языка"
}
check_ip(){
  echo "Проверка IP-адреса"
}
banner_1(){
  echo "Баннер 1"
}
start_installation(){
  echo "Начало установки"
}
data_entry(){
  echo "Ввод данных"
}
data_output(){
  echo "Вывод данных"
}
install(){
  echo "Установка панели"
}
log_entry(){
  echo "Начало логирования"
}

main() {
  log_entry
  read_defaults_from_file
  parse_args "$@" || show_help
  check_root
  check_ip
  check_operating_system
  select_language
  sleep 1
  clear
  if [ -f ${defaults_file} ]; then
    echo "повторная установка"
  fi
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
  [[ ${args[panel]} == "true" ]] && install
  [[ ${args[ufw]} == "true" ]] && enabling_security
  [[ ${args[ssh]} == "true" ]] && ssh_setup
  [[ ${args[tgbot]} == "true" ]] && install_bot
  data_output
  banner_1
  log_clear
}

main "$@"