#!/bin/bash

declare -A defaults
declare -A args
defaults_file="/usr/local/xui-rp/reinstall_defaults.conf"

# Функция для отображения справки

show_help() {
  echo ""
  echo "Usage: $0 [-i|--ipv6 <true|false>] [-w|--warp <true|false>] [-m|--monitoring <true|false>]"
  echo "       [-u|--ufw <true|false>] [-s|--ssh <true|false>] [-t|--tgbot <true|false>] [-h|--help]"
  echo ""
  echo "  -i, --ipv6 <true|false>         Enable or disable IPv6 (default: ${defaults[ipv6]})"
  echo "  -w, --warp <true|false>         Enable or disable Warp (default: ${defaults[warp]})"
  echo "  -m, --monitoring <true|false>   Enable or disable Monitoring (default: ${defaults[monitoring]})"
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
    while IFS="=" read -r key value; do
      defaults[$key]=$value
    done < $defaults_file
  else
    # Если файл не найден, используем значения по умолчанию
    defaults[ipv6]=true
    defaults[warp]=true
    defaults[monitoring]=OFF
    defaults[ufw]=true
    defaults[ssh]=true
    defaults[tgbot]=OFF
  fi
}

# Функция для записи значений в файл
write_defaults_to_file() {
  cat > ${defaults_file}<<EOF
defaults[ipv6]=false
defaults[warp]=false
defaults[monitoring]=false
defaults[ufw]=false
defaults[ssh]=true
defaults[tgbot]=false
EOF
}

normalize_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

parse_args() {
  local opts
  opts=$(getopt -o i:w:m:u:s:t:h --long ipv6:,warp:,monitoring:,ufw:,ssh:,tgbot:,help -- "$@")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  eval set -- "$opts"
  while true; do
    case $1 in
      -i|--ipv6)
        args[ipv6]="$2"
        normalize_case ipv6
        case ${args[ipv6]} in
          true)
            args[ipv6]=true
            shift 2
            ;;
          false)
            args[ipv6]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ipv6: $2. Use 'true' or 'false'."
            return 1
            ;;
        esac
        ;;

      -w|--warp)
        args[warp]="$2"
        normalize_case warp
        case ${args[warp]} in
          true)
            args[warp]=true
            shift 2
            ;;
          false)
            args[warp]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --warp: $2. Use 'true' or 'false'."
            return 1
            ;;
        esac
        ;;

      -m|--monitoring)
        args[monitoring]="$2"
        normalize_case monitoring
        case ${args[monitoring]} in
          true)
            args[monitoring]=true
            shift 2
            ;;
          false)
            args[monitoring]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --monitoring: $2. Use 'true' or 'false'."
            return 1
            ;;
        esac
        ;;

      -u|--ufw)
        args[ufw]="$2"
        normalize_case ufw
        case ${args[ufw]} in
          true)
            args[ufw]=true
            shift 2
            ;;
          false)
            args[ufw]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ufw: $2. Use 'true' or 'false'."
            return 1
            ;;
        esac
        ;;

      -s|--ssh)
        args[ssh]="$2"
        normalize_case ssh
        case ${args[ssh]} in
          true)
            args[ssh]=true
            shift 2
            ;;
          false)
            args[ssh]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ssh: $2. Use 'true' or 'false'."
            return 1
            ;;
        esac
        ;;

      -t|--tgbot)
        args[tgbot]="$2"
        normalize_case tgbot
        case ${args[tgbot]} in
          true)
            args[tgbot]=true
            shift 2
            ;;
          false)
            args[tgbot]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --tgbot: $2. Use 'true' or 'false'."
            return 1
            ;;
        esac
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

log_entry(){
  echo "Запись лога"
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

main() {
  log_entry
  read_defaults_from_file
  parse_args "$@" || show_help
  if [ -f ${defaults_file} ]; then
    echo "Повторный запуск"
    sleep 2
  fi
  check_root
  [[ ${args[ipv6]} == "true" ]] && disable_ipv6
  [[ ${args[warp]} == "true" ]] && warp
  issuance_of_certificates
  [[ ${args[monitoring]} == "true" ]] && monitoring
  nginx_setup
  write_defaults_to_file
  [[ ${args[ufw]} == "true" ]] && enabling_security
  [[ ${args[ssh]} == "true" ]] && ssh_setup
  [[ ${args[tgbot]} == "true" ]] && install_bot
  log_clear
}

main "$@"
