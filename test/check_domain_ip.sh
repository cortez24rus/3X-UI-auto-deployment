#!/bin/bash

###################################
### Obtaining your external IP address
###################################
check_ip() {
  IP4_REGEX="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"

  IP4=$(ip route get 8.8.8.8 2>/dev/null | grep -Po -- 'src \K\S*')

  if [[ ! $IP4 =~ $IP4_REGEX ]]; then
    IP4=$(curl -s --max-time 5 ipinfo.io/ip 2>/dev/null)
  fi

  if [[ ! $IP4 =~ $IP4_REGEX ]]; then
    echo "Не удалось получить внешний IP."
    return 1
  fi
  echo "$IP4"
}

###################################
### Obtaining a domain IP address
###################################
get_domain_ips() {
  IPS=($(dig @1.1.1.1 +short "$DOMAIN"))
  echo "${IPS[@]}"
}

###################################
### Checking if the IP is in range
###################################
ip_in_range() {
  local IP=$1
  local RANGE=$2
  ipcalc -n -c "$RANGE" | grep -q "$IP"
}

###################################
### IP checks
###################################
check_ip_in_cloudflare() {
  DOMAIN_IP=$1
  CLOUDFLARE_IPS=($(curl -s https://www.cloudflare.com/ips-v4))
  
  for RANGE in "${CLOUDFLARE_IPS[@]}"; do
    if ip_in_range "$DOMAIN_IP" "$RANGE"; then
      return 0
    fi
  done
  return 1
}

###################################
### Domain address verification
###################################
check_domain_ip() {
  local MY_IP
  local DOMAIN_IPS
  MY_IP=$(check_ip)
  DOMAIN_IPS=($(get_domain_ips))

  if [[ $? -ne 0 ]]; then
    echo "  Не удалось получить внешний IP, завершение выполнения"
    exit 1
  fi

  echo "  IP-адреса домена $DOMAIN: ${DOMAIN_IPS[@]}"

  if echo "${DOMAIN_IPS[@]}" | grep -qw "$MY_IP"; then
    echo "  Ваш IP совпадает с одним из IP домена $DOMAIN (Status Dns only)"
    echo
    return 0
  fi

  for IP in "${DOMAIN_IPS[@]}"; do
    if check_ip_in_cloudflare "$IP"; then
      echo "  IP-адрес $IP входит в диапазоны Cloudflare (Status Proxied)"
      echo
      return 0
    fi
  done

  echo "  Ни один из IP-адресов ${DOMAIN_IPS[@]} не входит в диапазоны Cloudflare."
  echo "|-------------------------------------------------------------------------|"
  exit 1
}

final() {
  echo "  Отработал на ура"
}

main() {
  apt install -y ipcalc > /dev/null 2>&1
  echo
  echo "|-------------------------------------------------------------------------|"
  DOMAIN="$@"
  check_domain_ip
  final
  echo "|-------------------------------------------------------------------------|"
  echo
}

main "$@"
