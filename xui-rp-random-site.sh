#!/bin/bash

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

mkdir -p /usr/local/xui-rp/
cd /usr/local/xui-rp/ || exit 1

if [[ ! -d "xui-rp-web-main" ]]; then
    while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/xui-rp-web/archive/refs/heads/main.zip"; do
        msg_err "Скачивание не удалось, пробуем снова..."
        sleep 3
    done
    unzip main.zip &>/dev/null && rm -f main.zip
fi

cd xui-rp-web-main || exit 1
rm -rf assets ".gitattributes" "README.md" "_config.yml"

RandomHTML=$(for i in *; do echo "$i"; done | shuf -n1 2>&1)
msg_inf "Random template name: ${RandomHTML}"

if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
    rm -rf /var/www/html/*
    cp -a "${RandomHTML}"/. "/var/www/html/"
    msg_ok "Template extracted successfully!"
else
    msg_err "Extraction error!" && exit 1
fi

cd ~/