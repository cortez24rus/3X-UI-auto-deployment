#!/bin/bash

declare -A defaults
declare -A args

defaults[ipver6]=ON
defaults[warp]=ON
defaults[monitoring]=OFF
defaults[ufw]=ON
defaults[ssh]=ON
defaults[tgbot]=OFF

function show_help {
  echo ""
  echo "Usage: $0 [-i|--ipver6 <on|off>] [-w|--warp <on|off>] [-m|--monitoring <on|off>]"
  echo "       [-u|--ufw <on|off>] [-s|--ssh <on|off>] [-t|--tgbot <on|off>] [-h|--help]"
  echo ""
  echo "  -i, --ipv6 <on|off>       Enable or disable IPv6 (default: ${defaults[ipver6]})"
  echo "  -w, --warp <on|off>         Enable or disable Warp (default: ${defaults[warp]})"
  echo "  -m, --monitoring <on|off>   Enable or disable Monitoring (default: ${defaults[monitoring]})"
  echo "  -u, --ufw <on|off>          Enable or disable UFW (default: ${defaults[ufw]})"
  echo "  -s, --ssh <on|off>          Enable or disable SSH (default: ${defaults[ssh]})"
  echo "  -t, --tgbot <on|off>        Enable or disable Telegram bot (default: ${defaults[tgbot]})"
  echo "  -h, --help                  Display this help message"
  echo ""
  exit 0
}

normalize_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

function parse_args {
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
          on)
            args[ipv6]=ON
            shift 2
            ;;
          off)
            args[ipv6]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ipv6: $2. Use 'on' or 'off'."
            return 1
            ;;
        esac
        ;;

      -w|--warp)
        args[warp]="$2"
        normalize_case warp
        case ${args[warp]} in
          on)
            args[warp]=ON
            shift 2
            ;;
          off)
            args[warp]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --warp: $2. Use 'on' or 'off'."
            return 1
            ;;
        esac
        ;;

      -m|--monitoring)
        args[monitoring]="$2"
        normalize_case monitoring
        case ${args[monitoring]} in
          on)
            args[monitoring]=ON
            shift 2
            ;;
          off)
            args[monitoring]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --monitoring: $2. Use 'on' or 'off'."
            return 1
            ;;
        esac
        ;;

      -u|--ufw)
        args[ufw]="$2"
        normalize_case ufw
        case ${args[ufw]} in
          on)
            args[ufw]=ON
            shift 2
            ;;
          off)
            args[ufw]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ufw: $2. Use 'on' or 'off'."
            return 1
            ;;
        esac
        ;;

      -s|--ssh)
        args[ssh]="$2"
        normalize_case ssh
        case ${args[ssh]} in
          on)
            args[ssh]=ON
            shift 2
            ;;
          off)
            args[ssh]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ssh: $2. Use 'on' or 'off'."
            return 1
            ;;
        esac
        ;;

      -t|--tgbot)
        args[tgbot]="$2"
        normalize_case tgbot
        case ${args[tgbot]} in
          on)
            args[tgbot]=ON
            shift 2
            ;;
          off)
            args[tgbot]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --tgbot: $2. Use 'on' or 'off'."
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

### Первый запуск ###
main_script_first() {
  echo "Начало"
  echo "--------------------"
  [[ ${args[ipver6]} == "ON" ]] && disable_ipv6
  [[ ${args[warp]} == "ON" ]] && warp
  issuance_of_certificates
  [[ ${args[monitoring]} == "ON" ]] && monitoring
  [[ ${args[ufw]} == "ON" ]] && enabling_security
  [[ ${args[ssh]} == "ON" ]] && ssh_setup
  [[ ${args[tgbot]} == "ON" ]] && install_bot
  echo "--------------------"
  echo "Конец"
}

### Проверка запуска ###
main_choise() {
  parse_args "$@" || show_help
  main_script_first
}

main_choise "$@"