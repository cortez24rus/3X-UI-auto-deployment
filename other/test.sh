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

out_data()   { echo -e "\e[1;33m$1\033[0m \033[38;5;214m$2\033[0m"; }
tilda()      { echo -e "\033[31m\033[38;5;214m$*\033[0m"; }
warning()    { echo -e "\033[31m [!]\033[38;5;214m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; exit 1; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
question()   { echo -e "\033[32m[?]\e[1;33m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp " $(question "$1")" "$2"; }
text()       { eval echo "\${${L}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${L}[$*]}")"; }

E[0]="Language:\n  1. English (default)\n  2. Русский\n  3. 中文\n  4. فارسی"
R[0]="Язык:\n  1. English (по умолчанию)\n  2.Русский\n  3. فارسی"
C[0]="语言:\n  1. English (默认)\n  2. Русский\n  3. 中文\n  4. فارسی"
P[0]="زبان:\n  1. English (پیش‌فرض)\n  2. Русский\n  3. 中文\n  4. فارسی"

E[1]="Choose:"
R[1]="Выбери:"
C[1]="选择:"
P[1]="انتخاب کنید:"

E[2]="Error: this script requires superuser (root) privileges to run."
R[2]="Ошибка: для выполнения этого скрипта необходимы права суперпользователя (root)."
C[2]="错误: 该脚本需要超级用户(root)权限才能运行。"
P[2]="خطا: این اسکریپت به دسترسی‌های کاربر ریشه (root) نیاز دارد."

E[3]="Unable to determine IP address."
R[3]="Не удалось определить IP-адрес."
C[3]="无法确定IP地址。"
P[3]="نمی‌توان آدرس IP را شناسایی کرد."

E[4]="Reinstalling script..."
R[4]="Повторная установка скрипта..."
C[4]="正在重新安装脚本..."
P[4]="در حال نصب مجدد اسکریپت..."

E[5]="WARNING!"
R[5]="ВНИМАНИЕ!"
C[5]="警告！"
P[5]="هشدار!"

E[6]="It is recommended to perform the following actions before running the script"
R[6]="Перед запуском скрипта рекомендуется выполнить следующие действия"
C[6]="建议在运行脚本之前执行以下操作"
P[6]="پیشنهاد می‌شود قبل از اجرای اسکریپت اقدامات زیر انجام شود."

E[7]=""
R[7]=""
C[7]=""
P[7]=""

E[8]="Start the XRAY installation? Choose option [y/N]:"
R[8]="Начать установку XRAY? Выберите опцию [y/N]:"
C[8]="开始XRAY安装？选择选项[y/N]："
P[8]="آیا می‌خواهید نصب XRAY را شروع کنید؟ گزینه را انتخاب کنید [y/N]:"

E[9]="CANCEL"
R[9]="ОТМЕНА"
C[9]="取消"
P[9]="لغو"

E[10]="\n|-----------------------------------------------------------------------------|\n"
R[10]="\n|-----------------------------------------------------------------------------|\n"
C[10]="\n|-----------------------------------------------------------------------------|\n"
P[10]="\n|-----------------------------------------------------------------------------|\n"

E[11]="Enter username:"
R[11]="Введите имя пользователя:"
C[11]="请输入用户名："
P[11]="نام کاربری را وارد کنید:"

E[12]="Enter user password:"
R[12]="Введите пароль пользователя:"
C[12]="请输入用户密码："
P[12]="رمز عبور کاربر را وارد کنید:"

E[13]="Enter your domain:"
R[13]="Введите ваш домен:"
C[13]="请输入您的域名："
P[13]="دامنه خود را وارد کنید:"

E[14]="Error: the entered address '$temp_value' is incorrectly formatted."
R[14]="Ошибка: введённый адрес '$temp_value' имеет неверный формат."
C[14]="错误：输入的地址 '$temp_value' 格式不正确。"
P[14]="خطا: آدرس وارد شده '$temp_value' به درستی فرمت نشده است."

E[15]="Enter your email registered with Cloudflare:"
R[15]="Введите вашу почту, зарегистрированную на Cloudflare:"
C[15]="请输入您的Cloudflare注册电子邮件："
P[15]="ایمیل خود را که در Cloudflare ثبت شده وارد کنید:"

E[16]="Enter your Cloudflare API token (Edit zone DNS) or global API key:"
R[16]="Введите ваш API токен Cloudflare (Edit zone DNS) или Cloudflare global API key:"
C[16]="请输入您的Cloudflare API令牌（编辑区域DNS）或全局API密钥："
P[16]="توکن API خود را از Cloudflare وارد کنید (Edit zone DNS) یا کلید API جهانی Cloudflare:"

E[17]="Verifying domain, API token/key, and email..."
R[17]="Проверка домена, API токена/ключа и почты..."
C[17]="正在验证域名、API令牌/密钥和电子邮件..."
P[17]="در حال بررسی دامنه، توکن/کلید API و ایمیل..."

E[18]="Error: invalid domain, API token/key, or email. Please try again."
R[18]="Ошибка: неправильно введён домен, API токен/ключ или почта. Попробуйте снова."
C[18]="错误：域名、API令牌/密钥或电子邮件无效。请再试一次。"
P[18]="خطا: دامنه، توکن/کلید API یا ایمیل نادرست است. لطفا دوباره امتحان کنید."

E[19]="Enter SNI for Reality:"
R[19]="Введите sni для Reality:"
C[19]="请输入Reality的SNI："
P[19]="SNI برای Reality را وارد کنید:"

E[20]="Enter Grpc path:"
R[20]="Введите путь к Grpc:"
C[20]="请输入Grpc路径："
P[20]="مسیر Grpc را وارد کنید:"

E[21]="Enter Split path:"
R[21]="Введите путь к Split:"
C[21]="请输入Split路径："
P[21]="مسیر Split را وارد کنید:"

E[22]="Enter HttpUpgrade path:"
R[22]="Введите путь к HttpUpgrade:"
C[22]="请输入HttpUpgrade路径："
P[22]="مسیر HttpUpgrade را وارد کنید:"

E[23]="Enter Websocket path:"
R[23]="Введите путь к Websocket:"
C[23]="请输入Websocket路径："
P[23]="مسیر Websocket را وارد کنید:"

E[24]="Enter Node Exporter path:"
R[24]="Введите путь к Node Exporter:"
C[24]="请输入Node Exporter路径："
P[24]="مسیر Node Exporter را وارد کنید:"

E[25]="Enter Adguard-home path:"
R[25]="Введите путь к Adguard-home:"
C[25]="请输入Adguard-home路径："
P[25]="مسیر Adguard-home را وارد کنید:"

E[26]="Enter panel path:"
R[26]="Введите путь к панели:"
C[26]="请输入面板路径："
P[26]="مسیر پنل را وارد کنید:"

E[27]="Enter subscription path:"
R[27]="Введите путь к подписке:"
C[27]="请输入订阅路径："
P[27]="مسیر اشتراک را وارد کنید:"

E[28]="Enter JSON subscription path:"
R[28]="Введите путь к JSON подписке:"
C[28]="请输入JSON订阅路径："
P[28]="مسیر اشتراک JSON را وارد کنید:"

E[29]="Error: path cannot be empty, please re-enter."
R[29]="Ошибка: путь не может быть пустым, повторите ввод."
C[29]="错误：路径不能为空，请重新输入。"
P[29]="خطا: مسیر نمی‌تواند خالی باشد، لطفا دوباره وارد کنید."

E[30]="Error: path must not contain characters {, }, /, $, \\, please re-enter."
R[30]="Ошибка: путь не должен содержать символы {, }, /, $, \\, повторите ввод."
C[30]="错误：路径不得包含字符{、}、/、$、\\，请重新输入。"
P[30]="خطا: مسیر نباید شامل کاراکترهای {،}، /، $، \\ باشد، لطفا دوباره وارد کنید."

E[31]="DNS server:\n  1. Systemd-resolved \n  2. Adguard-home"
R[31]="DNS сервер:\n  1. Systemd-resolved \n  2. Adguard-home"
C[31]="DNS服务器：\n  1. Systemd-resolved \n  2. Adguard-home"
P[31]="سرور DNS:\n  1. Systemd-resolved \n  2. Adguard-home"

E[32]="Systemd-resolved selected."
R[32]="Выбран systemd-resolved."
C[32]="选择了Systemd-resolved。"
P[32]="Systemd-resolved انتخاب شد."

E[33]="Error: invalid choice, please try again."
R[33]="Ошибка: неверный выбор, попробуйте снова."
C[33]="错误：无效的选择，请再试一次。"
P[33]="خطا: انتخاب نادرست، لطفا دوباره امتحان کنید."

E[34]="Enter Telegram bot token:"
R[34]="Введите токен Telegram бота:"
C[34]="请输入Telegram机器人令牌："
P[34]="توکن ربات تلگرام خود را وارد کنید:"

E[35]="Enter your Telegram ID:"
R[35]="Введите ваш Telegram ID:"
C[35]="请输入您的Telegram ID："
P[35]="شناسه تلگرام خود را وارد کنید:"

E[36]="Enter WebSocket address:"
R[36]="Введите адрес WebSocket:"
C[36]="请输入WebSocket地址："
P[36]="آدرس WebSocket را وارد کنید:"

E[37]="Enter panel URL:"
R[37]="Введите URL панели:"
C[37]="请输入面板URL："
P[37]="آدرس URL پنل را وارد کنید:"

E[38]="Enter subscription URL:"
R[38]="Введите URL подписки:"
C[38]="请输入订阅URL："
P[38]="آدرس URL اشتراک را وارد کنید:"

E[39]="Enter user authentication username:"
R[39]="Введите имя пользователя для аутентификации:"
C[39]="请输入身份验证用户名："
P[39]="نام کاربری برای احراز هویت را وارد کنید:"

E[40]="Enter user authentication password:"
R[40]="Введите пароль для аутентификации:"
C[40]="请输入身份验证密码："
P[40]="رمز عبور برای احراز هویت را وارد کنید:"

E[41]="Error: Authentication failed."
R[41]="Ошибка: не удалось пройти аутентификацию."
C[41]="错误：身份验证失败。"
P[41]="خطا: احراز هویت ناموفق بود."

E[42]="Adding user to the database..."
R[42]="Добавление пользователя в базу данных..."
C[42]="正在将用户添加到数据库..."
P[42]="در حال افزودن کاربر به پایگاه داده..."

E[43]="Removing user from the database..."
R[43]="Удаление пользователя из базы данных..."
C[43]="正在从数据库中删除用户..."
P[43]="در حال حذف کاربر از پایگاه داده..."

E[44]="Operation successful."
R[44]="Операция выполнена успешно."
C[44]="操作成功。"
P[44]="عملیات با موفقیت انجام شد."

E[45]="Error: User does not exist in the database."
R[45]="Ошибка: пользователь не существует в базе данных."
C[45]="错误：用户不存在数据库中。"
P[45]="خطا: کاربر در پایگاه داده وجود ندارد."

E[46]="Please try again later."
R[46]="Пожалуйста, попробуйте позже."
C[46]="请稍后再试。"
P[46]="لطفا بعدا دوباره امتحان کنید."

E[47]="Configuring UFW."
R[47]="Настройка UFW."
C[47]="正在配置UFW。"
P[47]="در حال پیکربندی UFW."

E[48]="Configuring SSH."
R[48]="Настройка SSH."
C[48]="正在配置SSH。"
P[48]="در حال پیکربندی SSH."

E[49]="Generate a key for your OS (ssh-keygen)."
R[49]="Сгенерируйте ключ для своей ОС (ssh-keygen)."
C[49]="为您的操作系统生成一个密钥（ssh-keygen）。"
P[49]="برای سیستم عامل خود یک کلید بسازید (ssh-keygen)."

E[50]="In Windows, install the openSSH package and enter the command in PowerShell (recommended to research key generation online)."
R[50]="В Windows нужно установить пакет openSSH и ввести команду в PowerShell (рекомендуется изучить генерацию ключей в интернете)."
C[50]="在Windows中，安装openSSH包并在PowerShell中输入命令（建议在线研究密钥生成）。"
P[50]="در ویندوز، بسته openSSH را نصب کنید و دستور را در PowerShell وارد کنید (پیشنهاد می‌شود که درباره‌ی تولید کلید آنلاین جستجو کنید)."

E[51]="If you are on Linux, you probably know what to do :C"
R[51]="Если у вас Linux, то вы сами все умеете :С"
C[51]="如果您使用Linux，您可能知道该怎么做：C"
P[51]="اگر شما لینوکس دارید، احتمالاً می‌دانید که چه کار کنید :C"

E[52]="Command for Windows:"
R[52]="Команда для Windows:"
C[52]="Windows的命令："
P[52]="دستور برای ویندوز:"

E[53]="Command for Linux:"
R[53]="Команда для Linux:"
C[53]="Linux的命令："
P[53]="دستور برای لینوکس:"

E[54]="Configure SSH (optional step)? [y/N]:"
R[54]="Настроить SSH (необязательный шаг)? [y/N]:"
C[54]="是否配置SSH（可选步骤）？[y/N]："
P[54]="آیا SSH را پیکربندی کنید (مرحله اختیاری)؟ [y/N]:"

E[55]="Error: keys not found in /home/${username}/.ssh/id_rsa.pub or /root/.ssh/id_rsa.pub"
R[55]="Ошибка: ключи не найдены в файле /home/${username}/.ssh/id_rsa.pub или /root/.ssh/id_rsa.pub"
C[55]="错误：在 /home/${username}/.ssh/id_rsa.pub 或 /root/.ssh/id_rsa.pub 中未找到密钥"
P[55]="خطا: کلیدها در /home/${username}/.ssh/id_rsa.pub یا /root/.ssh/id_rsa.pub یافت نشد."

E[56]="Create keys and add them to the server before retrying."
R[56]="Создайте ключи и добавьте их на сервер, прежде чем повторить снова."
C[56]="创建密钥并在重试之前将它们添加到服务器。"
P[56]="کلیدها را ایجاد کرده و قبل از تلاش مجدد آنها را به سرور اضافه کنید."

E[57]="Installing xui bot."
R[57]="Установка xui бота."
C[57]="正在安装xui机器人。"
P[57]="در حال نصب ربات xui."

E[58]="PLEASE SAVE THIS SCREEN!"
R[58]="ПОЖАЛУЙСТА, СОХРАНИ ЭТОТ ЭКРАН!"
C[58]="请保存此屏幕！"
P[58]="لطفاً این صفحه را ذخیره کنید!"

E[59]="Access the 3x-ui panel at the link:"
R[59]="Доступ по ссылке к 3x-ui панели:"
C[59]="访问3x-ui面板的链接："
P[59]="دسترسی به پنل 3x-ui از طریق لینک:"

E[60]="Quick subscription link for connection:"
R[60]="Быстрая ссылка на подписку для подключения:"
C[60]="连接的快速订阅链接："
P[60]="لینک سریع اشتراک برای اتصال:"

E[61]="Access Adguard-home at the link:"
R[61]="Доступ по ссылке к adguard-home:"
C[61]="访问Adguard-home的链接："
P[61]="دسترسی به Adguard-home از طریق لینک:"

E[62]="SSH connection:"
R[62]="Подключение по SSH:"
C[62]="SSH连接："
P[62]="اتصال SSH:"

E[63]="Username:"
R[63]="Имя пользователя:"
C[63]="用户名："
P[63]="نام کاربری:"

E[64]="Password:"
R[64]="Пароль:"
C[64]="密码："
P[64]="گذرواژه:"

E[65]="Log file path:"
R[65]="Путь к лог файлу:"
C[65]="日志文件路径："
P[65]="مسیر فایل لاگ:"

log_entry() {
    mkdir -p /usr/local/xui-rp/
    LOGFILE="/usr/local/xui-rp/xui-rp.log"
    exec > >(tee -a "$LOGFILE") 2>&1
}

select_language() {
  L=E
  hint " $(text 0) \n"  # Показывает информацию о доступных языках
  reading " $(text 1) " LANGUAGE  # Запрашивает выбор языка

  # Устанавливаем язык в зависимости от выбора
  case "$LANGUAGE" in
    1) L=E ;;   # Если выбран английский
    2) L=R ;;   # Если выбран русский
    3) L=C ;;   # Если выбран китайский
    4) L=F ;;   # Если выбран персидский
    *) L=E ;;   # По умолчанию — английский
  esac
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
    echo " ╻ ╻┏━┓┏━┓╻ ╻   ┏━┓┏━╸╻ ╻┏━╸┏━┓┏━┓┏━╸   ┏━┓┏━┓┏━┓╻ ╻╻ ╻ "
    echo " ┏╋┛┣┳┛┣━┫┗┳┛   ┣┳┛┣╸ ┃┏┛┣╸ ┣┳┛┗━┓┣╸    ┣━┛┣┳┛┃ ┃┏╋┛┗┳┛ "
    echo " ╹ ╹╹┗╸╹ ╹ ╹    ╹┗╸┗━╸┗┛ ┗━╸╹┗╸┗━┛┗━╸   ╹  ╹┗╸┗━┛╹ ╹ ╹  "
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
    reading " $(text 8) " answer
    case "${answer,,}" in
        y)  ;;
        *)
            error " $(text 9) "
            ;;
    esac
}

get_test_response() {
    testdomain=$(echo "${domain}" | rev | cut -d '.' -f 1-2 | rev)

    if [[ "$CFTOKEN" =~ [A-Z] ]]; then
        testdomain=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "Authorization: Bearer ${CFTOKEN}" --header "Content-Type: application/json")
    else
        testdomain=$(curl --silent --request GET --url https://api.cloudflare.com/client/v4/zones --header "X-Auth-Key: ${CFTOKEN}" --header "X-Auth-email: ${email}" --header "Content-Type: application/json")
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
        error " $(text 14) "
    fi

    # Возвращаем обработанный домен
    echo "$temp_value"
    return 0
}

check_cf_token() {
    while true; do
        while [[ -z $domain ]]; do
            reading " $(text 13) " domain
            echo
        done

        domain=$(crop_domain "$domain")

    if [[ $? -ne 0 ]]; then
            domain=""
            continue
        fi

        while [[ -z $email ]]; do
            reading " $(text 15) " email
            echo
        done

        while [[ -z $cftoken ]]; do
            reading " $(text 16) " cftoken
            echo
        done
        
        info " $(text 17) "

        if validate_input; then
            break
        else
            warning " $(text 18)"
            domain=""
            email=""
            cftoken=""
            echo
        fi
    done
}

# Функция для обработки пути с циклом
validate_path() {
    local variable_name="$1"
    local path_value

    # Проверка на пустое значение
    while true; do
        case "$variable_name" in
            CDNGRPC)
                reading " $(text 20) " path_value
                ;;
            CDNSPLIT)
                reading " $(text 21) " path_value
                ;;
            CDNHTTPU)
                reading " $(text 22) " path_value
                ;;
            CDNWS)
                reading " $(text 23) " path_value
                ;;
            METRICS)
                reading " $(text 24) " path_value
                ;;
            adguardpath)
                reading " $(text 25) " path_value
                ;;
            WEBBASEPATH)
                reading " $(text 26) " path_value
                ;;
            SUBPATH)
                reading " $(text 27) " path_value
                ;;                                
            SUBJSONPATH)
                reading " $(text 28) " path_value
                ;;                
        esac

        if [[ -z "$path_value" ]]; then
            warning " $(text 29) "
            echo
        elif [[ $path_value =~ ['{}\$/\\'] ]]; then
            warning " $(text 30) "
            echo
        else
            break
        fi
    done

    case "$variable_name" in
        CDNGRPC)
            export CDNGRPC="$path_value"
            ;;
        CDNSPLIT)
            export CDNSPLIT="$path_value"
            ;;
        CDNHTTPU)
            export CDNHTTPU="$path_value"
            ;;
        CDNWS)
            export CDNWS="$path_value"
            ;;
        METRICS)
            export METRICS="$path_value"
            ;;
        adguardpath)
            export adguardpath="$path_value"
            ;;
        WEBBASEPATH)
            export WEBBASEPATH="$path_value"
            ;;
        SUBPATH)
            export SUBPATH="$path_value"
            ;;
        SUBJSONPATH)
            export SUBJSONPATH="$path_value"
            ;;
    esac
}

choise_dns () {
    while true; do
        hint " $(text 31) \n" && reading " $(text 1) " choise
        case $choise in
            1)
                info " $(text 32) "
                echo
                break
                ;;
            2)
                tilda "$(text 10)"
                validate_path adguardpath
                echo
                break
                ;;
            *)
                info " $(text )"
                ;;
        esac
    done
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
        port=$(generate_port)
        if ! is_port_free $port; then  # Если порт свободен, выходим из цикла
            echo $port
            break
        fi
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
    validate_path WEBBASEPATH
    echo
    validate_path SUBPATH
    echo    
    validate_path SUBJSONPATH
    tilda "$(text 10)"
    if check_xuibot "$1"; then
        reading " $(text 34) " BOT_TOKEN
        echo
        reading " $(text 35) " AID
        tilda "$(text 10)"
    fi
    webPort=$(port_issuance)
    subPort=$(port_issuance)

    webCertFile=/etc/letsencrypt/live/${domain}/fullchain.pem
    webKeyFile=/etc/letsencrypt/live/${domain}/privkey.pem
    subURI=https://${domain}/${subPath}/
    subJsonURI=https://${domain}/${subJsonPath}/
}

### Обновление системы и установка пакетов ###
installation_of_utilities() {
    info " $(text 36) "
    apt-get update && apt-get upgrade -y && apt-get install -y \
        ufw \
        zip \
        wget \
        sudo \
        curl \
        gnupg2 \
        sqlite3 \
        certbot \
        net-tools \
        apache2-utils \
        unattended-upgrades \
        python3-certbot-dns-cloudflare
    
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
    gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
    if grep -q "bullseye" /etc/os-release || grep -q "bookworm" /etc/os-release; then
        echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
    else
        echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
    fi
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/99nginx
    
    apt-get update && apt-get install -y \
        nginx \
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
    while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz; do
        warning " $(text 38) "
        sleep 3
    done
    tar xvf AdGuardHome_linux_amd64.tar.gz

    AdGuardHome/AdGuardHome -s install
    hash=$(htpasswd -B -C 10 -n -b ${username} ${password} | cut -d ":" -f 2)

    rm -f AdGuardHome/AdGuardHome.yaml
    while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/adh/AdGuardHome.yaml" -O AdGuardHome/AdGuardHome.yaml; do
        warning " $(text 38) "
        sleep 3
    done

    sed -i \
      -e "s/\${username}/username/g" \
      -e "s/\${hash}/hash/g" \
      -e "s/\${username}/domain_temp/g" \
      -e "s/\${webCertFile}/fullchain.pem/g" \
      -e "s/\${webKeyFile}/privkey.pem/g" \
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
    case $choise in
        1)
            comment_agh="location /${adguardpath}/ {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Range \$http_range;
        proxy_set_header If-Range \$http_if_range;
        proxy_redirect /login.html /${adguardpath}/login.html;
        proxy_pass http://127.0.0.1:8081/;
        break;
    }"
            dns_adguard_home
            dns_systemd_resolved_for_adguard
            tilda "$(text 10)"
            ;;
        2)
            comment_agh=""
            tilda "$(text 10)"
            ;;
        *)
            error " $(text 3)"
            dns_encryption
            ;;
    esac
}

### Добавление пользователя ###
add_user() {
    info " $(text 39) "
    useradd -m -s $(which bash) -G sudo ${username}
    echo "${username}:${password}" | chpasswd
    mkdir -p /home/${username}/.ssh/
    touch /home/${username}/.ssh/authorized_keys
    chown ${username}: /home/${username}/.ssh
    chmod 700 /home/${username}/.ssh
    chown ${username}:${username} /home/${username}/.ssh/authorized_keys
    echo ${username}
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
    if [[ ! "$(sysctl net.core.default_qdisc)" == *"= fq" ]]
    then
        echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    fi
    if [[ ! "$(sysctl net.ipv4.tcp_congestion_control)" == *"bbr" ]]
    then
        echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    fi
}

### Отключение IPv6 ###
disable_ipv6() {
    info " $(text 42) "
    interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')
    if [[ ! "$(sysctl net.ipv6.conf.all.disable_ipv6)" == *"= 1" ]]
    then
        echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    fi
    if [[ ! "$(sysctl net.ipv6.conf.default.disable_ipv6)" == *"= 1" ]]
    then
        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    fi
    if [[ ! "$(sysctl net.ipv6.conf.lo.disable_ipv6)" == *"= 1" ]]
    then
        echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    fi
    if [[ ! "$(sysctl net.ipv6.conf.$interface_name.disable_ipv6)" == *"= 1" ]]
    then
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
    chown root:root cloudflare.credentials
    chmod 600 cloudflare.credentials
    if [[ "$cftoken" =~ [A-Z] ]]
    then
        echo "dns_cloudflare_api_token = ${cftoken}" >> /root/cloudflare.credentials
    else
        echo "dns_cloudflare_email = ${email}" >> /root/cloudflare.credentials
        echo "dns_cloudflare_api_key = ${cftoken}" >> /root/cloudflare.credentials
    fi
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials /root/cloudflare.credentials --dns-cloudflare-propagation-seconds 30 --rsa-key-size 4096 -d ${domain},*.${domain} --agree-tos -m ${email} --no-eff-email --non-interactive
    { crontab -l; echo "0 5 1 */2 * certbot -q renew"; } | crontab -
    echo "renew_hook = systemctl reload nginx" >> /etc/letsencrypt/renewal/${domain}.conf
    tilda "$(text 10)"
}

### NGINX ###
nginx_setup() {
    info " $(text 45) "
    mkdir -p /etc/nginx/stream-enabled/
    touch /etc/nginx/.htpasswd
    htpasswd -nb "$username" "$password" >> /etc/nginx/.htpasswd

    nginx_conf
    stream_conf
    local_conf
    random_site

    nginx -s reload
    tilda "$(text 10)"
}

nginx_conf() {
    cat > /etc/nginx/nginx.conf <<EOF
user                              www-data;
pid                               /run/nginx.pid;
worker_processes                  auto;
worker_rlimit_nofile              65535;
error_log                         /var/log/nginx/error.log;
include                           /etc/nginx/modules-enabled/*.conf;

events {
    multi_accept                  on;
    worker_connections            65535;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

#   access_log                    /var/log/nginx/access.log  main;
    sendfile                      on;
    tcp_nopush                    on;
    tcp_nodelay                   on;
    server_tokens                 off;
    log_not_found                 off;
    types_hash_max_size           2048;
    types_hash_bucket_size        64;
    client_max_body_size          16M;

    # timeout
    keepalive_timeout             60s;
    keepalive_requests            1000;
    reset_timedout_connection     on;

    # MIME
    include                       /etc/nginx/mime.types;
    default_type                  application/octet-stream;

    # SSL
    ssl_session_timeout           1d;
    ssl_session_cache             shared:SSL:10m;
    ssl_session_tickets           off;

    # Mozilla Intermediate configuration
    ssl_prefer_server_ciphers on;
    ssl_protocols                 TLSv1.2 TLSv1.3;
    ssl_ciphers                   TLS13_AES_128_GCM_SHA256:TLS13_AES_256_GCM_SHA384:TLS13_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305;

    # OCSP Stapling
    ssl_stapling                  on;
    ssl_stapling_verify           on;
    resolver                      1.1.1.1 valid=60s;
    resolver_timeout              2s;

    gzip                          on;

    include                       /etc/nginx/conf.d/*.conf;
}

stream {
    include /etc/nginx/stream-enabled/stream.conf;
}
EOF
}

stream_conf() {
    cat > /etc/nginx/stream-enabled/stream.conf <<EOF
map \$ssl_preread_protocol \$backend {
    default \$https;
    "" ssh;
}
map \$ssl_preread_server_name \$https {
    ${domain}      web;
    ${reality}     reality;
    www.${domain}  xtls;
}
upstream web             { server 127.0.0.1:7443; }
#upstream web             { server 127.0.0.1:46076; }
upstream reality         { server 127.0.0.1:8443; }
upstream xtls            { server 127.0.0.1:9443; }
#upstream ssh             { server 127.0.0.1:36079; }

server {
    listen 443           reuseport;
    ssl_preread          on;
    proxy_pass           \$backend;
}
EOF
}

local_conf() {
    cat > /etc/nginx/conf.d/local.conf <<EOF
server {
     listen 9090 default_server;
     server_name _;
     location / {
         return 301  https://${domain}\$request_uri;
     }
}
# Main
server {
    listen                      46076 ssl default_server;

    # SSL
    ssl_reject_handshake        on;
    ssl_session_timeout         1h;
    ssl_session_cache           shared:SSL:10m;
}
server {
#    listen                      46076 ssl http2;
    listen                      46076 ssl http2 proxy_protocol;
    set_real_ip_from            127.0.0.1;
    real_ip_header              proxy_protocol;
    server_name                 ${domain} www.${domain};

    # SSL
    ssl_certificate             ${webCertFile};
    ssl_certificate_key         ${webKeyFile};
    ssl_trusted_certificate     /etc/letsencrypt/live/${domain}/chain.pem;

    index index.html index.htm index.php index.nginx-debian.html;
    root /var/www/html/;

    # Security headers
    add_header X-XSS-Protection          "1; mode=block" always;
    add_header X-Content-Type-Options    "nosniff" always;
    add_header Referrer-Policy           "no-referrer-when-downgrade" always;
#    add_header Content-Security-Policy   "default-src https:; script-src https: 'unsafe-inline' 'unsafe-eval'; style-src https: 'unsafe-inline';" always;
    add_header Permissions-Policy        "interest-cohort=()" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options           "SAMEORIGIN";
    proxy_hide_header X-Powered-By;

    # Security
    if (\$host !~* ^(.+\.)?${domain}\$ ){return 444;}
    if (\$scheme ~* https) {set \$safe 1;}
    if (\$ssl_server_name !~* ^(.+\.)?${domain}\$ ) {set \$safe "\${safe}0"; }
    if (\$safe = 10){return 444;}
    if (\$request_uri ~ "(\"|'|\`|~|,|:|--|;|%|\\$|&&|\?\?|0x00|0X00|\||\\|\{|\}|\[|\]|<|>|\.\.\.|\.\.\/|\/\/\/)"){set \$hack 1;}
    error_page 400 401 402 403 500 501 502 503 504 =404 /404;
    proxy_intercept_errors on;

    # Disable direct IP access
    if (\$host = ${IP4}) {
        return 444;
    }

#    location / {
#        auth_basic "Restricted Content";
#        auth_basic_user_file /etc/nginx/.htpasswd;
#    }
     location /${node_metrics} {
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://127.0.0.1:9100/metrics;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    location ~* /(sub|dashboard|api|docs|redoc|openapi.json|statics) {
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass https://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    # X-ui Admin panel
    location /${webBasePath} {
        proxy_redirect off;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Range \$http_range;
        proxy_set_header If-Range \$http_if_range;
        proxy_pass https://127.0.0.1:${webPort}/${webBasePath};
        break;
    }
    # Subscription
    location /${subPath} {
        if (\$hack = 1) {return 404;}
        proxy_redirect off;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass https://127.0.0.1:${subPort}/${subPath};
        break;
    }
    # Subscription json
    location /${subJsonPath} {
        if (\$hack = 1) {return 404;}
        proxy_redirect off;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass https://127.0.0.1:${subPort}/${subJsonPath};
        break;
    }
    location /${cdnsplit} {
        proxy_pass http://127.0.0.1:2063;
        proxy_http_version 1.1;
        proxy_redirect off;
    }
    # Xray Config
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
        if (\$http_upgrade ~* "(WEBSOCKET|WS)") {
            proxy_pass https://127.0.0.1:\$fwdport\$is_args\$args;
            break;
            }
        if (\$request_method ~* ^(PUT|POST|GET)\$) {
            proxy_pass http://127.0.0.1:\$fwdport\$is_args\$args;
            break;
        }
    }
    # Adguard home
    ${comment_agh}
}
EOF
}

random_site() {
    bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-random-site.sh)
}

monitoring() {
    bash <(curl -Ls https://github.com/cortez24rus/grafana-prometheus/raw/refs/heads/main/prometheus_node_exporter.sh)
}

generate_keys() {
    # Генерация пары ключей X25519 с использованием xray
    local key_pair=$(/usr/local/x-ui/bin/xray-linux-amd64 x25519)
    local private_key=$(echo "$key_pair" | grep "Private key:" | awk '{print $3}')
    local public_key=$(echo "$key_pair" | grep "Public key:" | awk '{print $3}')

    # Возвращаем ключи в виде строки, разделенной пробелом
    echo "$private_key $public_key"
}

### Изменение базы данных ###
stream_settings_grpc() {
    stream_settings_grpc=$(cat <<EOF
{
  "network": "grpc",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "grpcSettings": {
    "serviceName": "/2053/${cdngrpc}",
    "authority": "${domain}",
    "multiMode": false
  }
}
EOF
)
}

stream_settings_split() {
    stream_settings_split=$(cat <<EOF
{
  "network": "splithttp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "splithttpSettings": {
    "path": "/${cdnsplit}",
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
    }
  }
}
EOF
)
}

stream_settings_httpu() {
    stream_settings_httpu=$(cat <<EOF
{
  "network": "httpupgrade",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "",
    "minVersion": "1.2",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
        "certificateFile": "${webCertFile}",
        "keyFile": "${webKeyFile}",
        "ocspStapling": 3600,
        "oneTimeLoading": false,
        "usage": "encipherment",
        "buildChain": false
      }
    ],
    "alpn": [],
    "settings": {
      "allowInsecure": false,
      "fingerprint": "randomized"
    }
  },
  "httpupgradeSettings": {
    "acceptProxyProtocol": false,
    "path": "/2073/${cdnhttpu}",
    "host": "${domain}",
    "headers": {}
  }
}
EOF
)
}

stream_settings_ws() {
    stream_settings_ws=$(cat <<EOF
{
  "network": "ws",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "${domain}",
    "minVersion": "1.2",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
        "certificateFile": "${webCertFile}",
        "keyFile": "${webKeyFile}",
        "ocspStapling": 3600,
        "oneTimeLoading": false,
        "usage": "encipherment",
        "buildChain": false
      }
    ],
    "alpn": [],
    "settings": {
      "allowInsecure": false,
      "fingerprint": "randomized"
    }
  },
  "wsSettings": {
    "acceptProxyProtocol": false,
    "path": "/2083/${cdnws}",
    "host": "${domain}",
    "headers": {}
  }
}
EOF
)
}

stream_settings_steal() {
    read private_key public_key <<< "$(generate_keys)"

    stream_settings_steal=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "realitySettings": {
    "show": false,
    "xver": 2,
    "dest": "46076",
    "serverNames": [
      "${domain}"
    ],
    "privateKey": "${private_key}",
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
      "publicKey": "${public_key}",
      "fingerprint": "randomized",
      "serverName": "",
      "spiderX": "/"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
)
}

stream_settings_reality() {
    read private_key public_key <<< "$(generate_keys)"

    stream_settings_reality=$(cat <<EOF
{
  "network": "tcp",
  "security": "reality",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "realitySettings": {
    "show": false,
    "xver": 2,
    "dest": "${reality}:443",
    "serverNames": [
      "${reality}"
    ],
    "privateKey": "${private_key}",
    "minClient": "",
    "maxClient": "",
    "maxTimediff": 0,
    "shortIds": [
      "cd95c9",
      "eeed8008",
      "f2e26eba6c9432cf",
      "0d6a8b47988f0d",
      "c1",
      "1b60e7369779",
      "7fb9d5f9d8",
      "6696"
    ],
    "settings": {
      "publicKey": "${public_key}",
      "fingerprint": "randomized",
      "serverName": "",
      "spiderX": "/"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
)
}

stream_settings_xtls() {
    stream_settings_xtls=$(cat <<EOF
{
  "network": "tcp",
  "security": "tls",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 443,
      "remark": ""
    }
  ],
  "tlsSettings": {
    "serverName": "www.${domain}",
    "minVersion": "1.3",
    "maxVersion": "1.3",
    "cipherSuites": "",
    "rejectUnknownSni": false,
    "disableSystemRoot": false,
    "enableSessionResumption": false,
    "certificates": [
      {
        "certificateFile": "${webCertFile}",
        "keyFile": "${webKeyFile}",
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
      "fingerprint": "randomized"
    }
  },
  "tcpSettings": {
    "acceptProxyProtocol": false,
    "header": {
      "type": "none"
    }
  }
}
EOF
)
}

stream_settings_mkcp() {
    stream_settings_mkcp=$(cat <<EOF
{
  "network": "kcp",
  "security": "none",
  "externalProxy": [
    {
      "forceTls": "same",
      "dest": "www.${domain}",
      "port": 9999,
      "remark": ""
    }
  ],
  "kcpSettings": {
    "mtu": 1350,
    "tti": 20,
    "uplinkCapacity": 50,
    "downlinkCapacity": 100,
    "congestion": false,
    "readBufferSize": 1,
    "writeBufferSize": 1,
    "header": {
      "type": "srtp"
    },
    "seed": "iTsaMjully"
  }
}
EOF
)
}

database_change() {
    DB_PATH="x-ui.db"

    sqlite3 $DB_PATH <<EOF
UPDATE users SET username = '$username' WHERE id = 1;
UPDATE users SET password = '$password' WHERE id = 1;

UPDATE inbounds SET stream_settings = '$stream_settings_grpc' WHERE remark = '☁gRPC';
UPDATE inbounds SET stream_settings = '$stream_settings_split' WHERE remark = '☁Split';
UPDATE inbounds SET stream_settings = '$stream_settings_httpu' WHERE remark = '☁HttpU';
UPDATE inbounds SET stream_settings = '$stream_settings_ws' WHERE remark = '☁WS';
UPDATE inbounds SET stream_settings = '$stream_settings_steal' WHERE remark = '🥷🏻Steal';
UPDATE inbounds SET stream_settings = '$stream_settings_reality' WHERE remark = '🥷🏻Whatsapp';
UPDATE inbounds SET stream_settings = '$stream_settings_xtls' WHERE remark = '✖️XTLS';
UPDATE inbounds SET stream_settings = '$stream_settings_mkcp' WHERE remark = '📲MKCP';

UPDATE settings SET value = '${webPort}' WHERE key = 'webPort';
UPDATE settings SET value = '/${webBasePath}/' WHERE key = 'webBasePath';
UPDATE settings SET value = '${webCertFile}' WHERE key = 'webCertFile';
UPDATE settings SET value = '${webKeyFile}' WHERE key = 'webKeyFile';
UPDATE settings SET value = '${subPort}' WHERE key = 'subPort';
UPDATE settings SET value = '/${subPath}/' WHERE key = 'subPath';
UPDATE settings SET value = '${webCertFile}' WHERE key = 'subCertFile';
UPDATE settings SET value = '${webKeyFile}' WHERE key = 'subKeyFile';
UPDATE settings SET value = '${subURI}' WHERE key = 'subURI';
UPDATE settings SET value = '/${subJsonPath}/' WHERE key = 'subJsonPath';
UPDATE settings SET value = '${subJsonURI}' WHERE key = 'subJsonURI';
EOF
}

### Установка 3x-ui ###
panel_installation() {
    info " $(text 46) "
    touch /usr/local/xui-rp/reinstallation_check

    while ! wget -q --show-progress --timeout=30 --tries=10 --retry-connrefused https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/other/x-ui.gpg; do
        warning " $(text 38) "
        sleep 3
    done
    
    echo ${password} | gpg --batch --yes --passphrase-fd 0 -d x-ui.gpg > x-ui.db
    echo -e "n" | bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) > /dev/null 2>&1

    stream_settings_grpc
    stream_settings_split
    stream_settings_httpu
    stream_settings_ws
    stream_settings_steal
    stream_settings_reality
    stream_settings_xtls
    stream_settings_mkcp
    database_change

    x-ui stop
    
    rm -rf x-ui.gpg
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
    info " $(text 49) "
    echo
    info " $(text 50) "
    info " $(text 51) "
    tilda "$(text 10)"
    out_data " $(text 52)" "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${username}@${IP4} \"cat >> ~/.ssh/authorized_keys\""
    out_data " $(text 53)" "ssh-copy-id -p 22 ${username}@${IP4}"
    tilda "$(text 10)"
    while true; do
        reading " $(text 54) " answer_ssh
        case "${answer_ssh,,}" in
            y)  ;;
            *)
                error " $(text 9) "
                ;;
        esac
        
        if [[ $? -eq 0 ]]; then
            if [[ ! -s /home/${username}/.ssh/id_rsa.pub && ! -s /root/.ssh/id_rsa.pub ]]; then
                warning " $(text 55) "
                info " $(text 56) "
                echo
            else
                # Если ключи найдены, продолжаем настройку SSH
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
                systemctl restart ssh.service
                break
            fi
        else
            break
        fi
    done

    tilda "$(text 10)"
}

# Установока xui бота
install_xuibot() {
    info " $(text 57) "
    if [[ "$1" == "-bot" ]]; then
         bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install-bot.sh) "$BOT_TOKEN" "$AID" "$domain"
    fi
}

### Окончание ###
data_output() {
    info " $(text 58) "
    msg_err "PLEASE SAVE THIS SCREEN!"
    printf '0\n' | x-ui | grep --color=never -i ':'
    tilda "$(text 10)"
    out_data " $(text 59) " "https://${domain}/${webBasePath}/"
    out_data " $(text 60) " "${subURI}user"
    if [[ $choise = "1" ]]; then
        out_data " $(text 61) " "https://${domain}/${adguardPath}/login.html"
        
    fi
    tilda "$(text 10)"
    out_data " $(text 62) " "ssh -p 36079 ${username}@${IP4}"
    tilda "$(text 10)"
    out_data " $(text 63) " "$username"
    out_data " $(text 64) " "$password"
    tilda "$(text 10)"
    out_data " $(text 64) " "$LOGFILE"
    tilda "$(text 10)"
}

# Удаление всех управляющих последовательностей
log_clear() {
    sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$LOGFILE"
}

### Первый запуск ###
main_script_first() {
    check_root
    clear
    check_ip
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
    check_root
    clear
    check_ip
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
    if [ -f /usr/local/xui-rp/reinstallation_check ]; then
        info " $(text 4) "
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