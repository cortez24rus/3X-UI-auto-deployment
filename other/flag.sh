#!/bin/bash

declare -A defaults
declare -A args

defaults[ipver6]=ON
defaults[warp]=ON
defaults[monitoring]=OFF
defaults[ufw]=ON
defaults[ssh]=ON
defaults[tgbot]=OFF

normalize_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

function parse_args {
  local opts
  opts=$(getopt -o i:w:m:u:s:t:h --long ipver6:,warp:,monitoring:,ufw:,ssh:,tgbot:,help -- "$@")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  eval set -- "$opts"
  while true; do
    case $1 in
      -i|--ipver6)
        args[ipver6]="$2"
        normalize_case ipver6
        case ${args[ipver6]} in
          on)
            args[ipver6]=ON
            shift 2
            ;;
          off)
            args[ipver6]=OFF
            shift 2
            ;;
          *)
            echo "Invalid option for --ipver6: $2. Use 'on' or 'off'."
            return 1
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
}

ssh_setup(){
  echo "INSTALL SSH"  
}

warp(){
  echo "INSTALL SSH"  
}

monitor(){
  echo "INSTALL SSH"  
}

### Первый запуск ###
main_script_first() {
  clear
  check_ip
  banner_1
  start_installation
  data_entry
  installation_of_utilities
  dns_encryption
  add_user
  unattended_upgrade
  enable_bbr
  [[ ${args[ipver6]} == "ON" ]] && disable_ipv6
  [[ ${args[warp]} == "ON" ]] && warp
  issuance_of_certificates
  [[ ${args[monitoring]} == "ON" ]] && monitoring
  nginx_setup
  panel_installation
  [[ ${args[ufw]} == "ON" ]] && enabling_security
  [[ ${args[ssh]} == "ON" ]] && ssh_setup
  [[ ${args[tgbot]} == "ON" ]] && install_bot
  data_output
  banner_1
  log_clear
}

### Проверка запуска ###
main_choise() {
  log_entry
  parse_args "$@"
  check_root
  check_operating_system
  select_language
  main_script_first
}

main_choise "$@"
