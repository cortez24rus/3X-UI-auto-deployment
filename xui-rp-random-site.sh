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

msg_banner "Обновляем пакеты и устанавливаем zip..."
apt-get update -y && apt-get install -y zip wget unzip || { msg_err "Ошибка при установке пакетов"; exit 1; }

msg_banner "Создаем необходимые папки..."
mkdir -p /var/www/html/ /usr/local/xui-rp/

cd /usr/local/xui-rp/ || { msg_err "Не удалось перейти в /usr/local/xui-rp/"; exit 1; }

if [[ ! -d "simple-web-templates-main" ]]; then
    msg_inf "Скачиваем шаблоны..."
    while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/simple-web-templates/archive/refs/heads/main.zip"; do
        msg_err "Скачивание не удалось, пробуем снова..."
        sleep 3
    done
    unzip -q main.zip &>/dev/null && rm -f main.zip
fi

cd simple-web-templates-main || { msg_err "Не удалось перейти в папку с шаблонами"; exit 1; }

msg_inf "Удаляем ненужные файлы..."
rm -rf assets ".gitattributes" "README.md" "_config.yml"

RandomHTML=$(ls -d */ | shuf -n1)  # Обновил для выбора случайного подкаталога
msg_inf "Random template name: ${RandomHTML}"

# Если шаблон существует, копируем его в /var/www/html
if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
    msg_inf "Копируем шаблон в /var/www/html/..."
    rm -rf /var/www/html/*  # Очищаем старую папку
    cp -a "${RandomHTML}/." /var/www/html/ || { msg_err "Ошибка при копировании шаблона"; exit 1; }
    msg_ok "Шаблон успешно извлечен и установлен!"
else
    msg_err "Ошибка при извлечении шаблона!"
    exit 1
fi

cd ~ || { msg_err "Не удалось вернуться в домашнюю директорию"; exit 1; }
