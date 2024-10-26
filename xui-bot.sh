#!/bin/bash

# Проверка на наличие параметра TOKEN
if [ -z "$1" ]; then
    echo "Ошибка: Пожалуйста, передайте TOKEN как параметр."
    echo "Использование: $0 <TOKEN>"
    exit 1
fi

# Установка параметра TOKEN
TOKEN="$1"

# Установка пакетов
apt-get update && apt-get install -y python3 \
python3-pip \
python3-venv

# Создание директорий и т.д...
mkdir -p /usr/local/bot-x-ui/
python3 -m venv /usr/local/bot-x-ui/xuibotenv

# XUI бот
cat > /usr/local/bot-x-ui/x-ui-bot.py <<EOF
import sqlite3
import json
import uuid
from telegram import InlineKeyboardButton, InlineKeyboardMarkup, Update
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, ContextTypes, MessageHandler
from telegram.ext import filters
from datetime import datetime, timedelta

# Вводные данные
DB_PATH = '/etc/x-ui/x-ui.db'
BOT_ID = '${TOKEN}'

# Функция для подключения к базе данных
def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

# Функция для получения всех remark с up и down
def get_inbounds_remarks():
    connection = sqlite3.connect(DB_PATH)
    cursor = connection.cursor()

    cursor.execute("SELECT remark, up, down, enable FROM inbounds")
    remarks = cursor.fetchall()

    connection.close()
    return [(remark, up, down, enable) for remark, up, down, enable in remarks]

# Функция для получения всех существующих ID
def get_all_ids():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT id, settings FROM inbounds")
    result = cursor.fetchall()
    conn.close()
    return [(id, json.loads(settings)) for id, settings in result]

# Функция для получения всех пользователей
def get_all_users():
    all_ids = get_all_ids()
    users = []
    for _, settings in all_ids:
        for client in settings.get('clients', []):
            users.append(client['subId'])  # Добавляем subId пользователя в список
    return list(set(users))  # Удаляем дубликаты

# Функция для добавления пользователя
def add_user_to_all_ids(name):
    all_ids = get_all_ids()

    for id, settings in all_ids:
        # Получаем remark для текущего id
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute("SELECT remark FROM inbounds WHERE id = ?", (id,))
        remark = cursor.fetchone()[0]  # Получаем значение remark
        conn.close()

        # Используем имя для формирования email с remark
        email = f"{name}{remark}"  # Формируем email на основе имени пользователя и remark

        # Генерируем уникальный UUID для id
        new_id = str(uuid.uuid4())

        # Получаем текущее время и добавляем два дня
        expiry_time = int((datetime.now() + timedelta(days=2)).timestamp() * 1000)

        new_client = {
            "id": new_id,  # Генерируем уникальный id
            "flow": "",
            "email": email,  # Email теперь на основе имени и remark
            "limitIp": 2,
            "totalGB": 0,
            "expiryTime": expiry_time,  # Текущее время + 2 дня в Unix формате
            "enable": True,
            "tgId": "",
            "subId": name,  # Используем введённое имя как subId
            "reset": 30
        }

        settings['clients'].append(new_client)
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(settings), id))
        conn.commit()
        conn.close()

# Функция для обновления значения enable в базе данных
def toggle_enable(remark):
    connection = sqlite3.connect(DB_PATH)
    cursor = connection.cursor()

    cursor.execute("SELECT enable FROM inbounds WHERE remark = ?", (remark,))
    current_value = cursor.fetchone()

    if current_value:
        new_value = 1 if current_value[0] == 0 else 0
        cursor.execute("UPDATE inbounds SET enable = ? WHERE remark = ?", (new_value, remark))
        connection.commit()

    connection.close()
    return new_value

# Функция для удаления пользователя по subId
def remove_user_from_all_ids(subId):
    all_ids = get_all_ids()
    for id, settings in all_ids:
        # Фильтруем клиентов, исключая удаляемого
        settings['clients'] = [client for client in settings['clients'] if client['subId'] != subId]

        # Обновление базы данных
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(settings), id))
        conn.commit()
        conn.close()

# Функция для получения информации о пользователях из базы данных
def get_users_info():
    conn = get_db_connection()
    cursor = conn.cursor()

    # Получение значения suburl
    cursor.execute("SELECT value FROM settings WHERE key = 'subURI'")
    suburl_row = cursor.fetchone()
    suburl = suburl_row[0] if suburl_row else ""  # Убедимся, что значение suburl получено

    # Запрос для получения всех данных из таблицы inbounds
    cursor.execute("SELECT settings FROM inbounds")
    inbounds = cursor.fetchall()

    user_lines = set()  # Используем set для удаления дубликатов

    # Обработка данных
    for inbound in inbounds:
        settings = json.loads(inbound['settings'])
        for client in settings.get('clients', []):
            sub_id = client.get('subId')
            if sub_id:
                # Запрос для получения трафика пользователя
                cursor.execute("SELECT up, down FROM client_traffics WHERE email = ?", (client.get('email'),))
                traffic = cursor.fetchone()
                up_traffic = traffic[0] / (1024 ** 3) if traffic and traffic[0] is not None else 0  # в гигабайтах
                down_traffic = traffic[1] / (1024 ** 3) if traffic and traffic[1] is not None else 0  # в гигабайтах

                # Форматирование ссылки с использованием suburl
                subscription_link = f"🔗{suburl}{sub_id}" if suburl else f"/{sub_id}"

                # Форматирование вывода
                user_lines.add(f"👤{sub_id} - ↘️{up_traffic:.2f} GB / ↗️{down_traffic:.2f} GB\n{subscription_link}")

    conn.close()  # Закрываем соединение после завершения всех операций
    return "\n\n".join(user_lines) if user_lines else "No users"

# Функция для обработки команды /start
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    keyboard = [
        [InlineKeyboardButton("START", callback_data='open_menu')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    if update.message:
        await update.message.reply_text("Mini XRAY bot", reply_markup=reply_markup)
    else:
        await update.callback_query.edit_message_text("Mini XRAY bot", reply_markup=reply_markup)

# Функция для обработки нажатия кнопок
async def button_click(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
   
    await query.answer()
    if query.data == 'open_menu':
        keyboard = [
            [InlineKeyboardButton("📬Inbounds", callback_data='inbounds')],
            [InlineKeyboardButton("🫂User menu", callback_data='user_menu')]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text("🎛Main menu🎛", reply_markup=reply_markup)

    elif query.data == 'user_menu':
        await show_user_menu(query)

    elif query.data == 'show_users':
        users_info = get_users_info()
        keyboard = [
            [InlineKeyboardButton("🔙Return", callback_data='user_menu')]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text(text=users_info, reply_markup=reply_markup)

    elif query.data == 'inbounds':
        remarks = get_inbounds_remarks()
        if remarks:
            keyboard = [
                [InlineKeyboardButton(
                    f"{remark} - {up / (1024 ** 3):.2f} GB / {down / (1024 ** 3):.2f} GB - {'🟢' if enable == 1 else '🔴'}",
                    callback_data=remark
                )]
                for remark, up, down, enable in remarks
            ]
            keyboard.append([InlineKeyboardButton("🔙Return", callback_data='open_menu')])
            reply_markup = InlineKeyboardMarkup(keyboard)
            await query.edit_message_text("📬Select inbound📬", reply_markup=reply_markup)
        else:
            await query.edit_message_text("No inbounds available")

    elif query.data in (remark for remark, _, _, _ in get_inbounds_remarks()):
        new_enable_value = toggle_enable(query.data)
        remarks = get_inbounds_remarks()
        keyboard = [
            [InlineKeyboardButton(
                f"{remark} - {up / (1024 ** 3):.2f} GB / {down / (1024 ** 3):.2f} GB - {'🟢' if enable == 1 else '🔴'}",
                callback_data=remark
            )]
            for remark, up, down, enable in remarks
        ]
        keyboard.append([InlineKeyboardButton("🔙Return", callback_data='inbounds')])
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text("Select inbound", reply_markup=reply_markup)
    elif query.data in (remark for remark, _, _, _ in get_inbounds_remarks()):
        new_enable_value = toggle_enable(query.data)
        await button_click(update, context)  # Обновляем интерфейс, повторно вызывая функцию

    elif query.data == 'add_user':
        await query.message.reply_text("Please enter a username to add")
        context.user_data['action'] = 'add_user'

    elif query.data == 'delete_user':
        users = get_all_users()
        if users:
            await show_delete_user_menu(query, users)
        else:
            await query.edit_message_text("No users available")

    elif query.data.startswith('remove_'):
        subId = query.data.split('_')[1]  # Извлекаем subId из callback_data
        remove_user_from_all_ids(subId)  # Удаляем пользователя из всех inbounds

        # Обновляем список пользователей
        users = get_all_users()
        await show_delete_user_menu(query, users)

async def show_user_menu(query):
    keyboard = [
        [InlineKeyboardButton("✅Add user", callback_data='add_user')],
        [InlineKeyboardButton("❌Delete user", callback_data='delete_user')],
        [InlineKeyboardButton("💵Subscription/📊traffic used", callback_data='show_users')],
        [InlineKeyboardButton("🔙Return", callback_data='open_menu')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await query.edit_message_text("🫂User menu🫂", reply_markup=reply_markup)

async def show_delete_user_menu(query, users):
    keyboard = []
    for i, user in enumerate(users):
        # Добавляем пользователей в две колонки
        if i % 2 == 0:
            keyboard.append([InlineKeyboardButton(user, callback_data=f'remove_{user}')])
        else:
            keyboard[-1].append(InlineKeyboardButton(user, callback_data=f'remove_{user}'))
    keyboard.append([InlineKeyboardButton("🔙Return", callback_data='user_menu')])
    reply_markup = InlineKeyboardMarkup(keyboard)
    await query.edit_message_text("❌Select the user to delete❌", reply_markup=reply_markup)

async def message_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    action = context.user_data.get('action')
    if action == 'add_user':
        name = update.message.text
        add_user_to_all_ids(name)
        await update.message.reply_text(f"User {name} added")
        context.user_data['action'] = None

if __name__ == '__main__':
    application = ApplicationBuilder().token(BOT_ID).build()

    # Регистрация обработчиков команд и сообщений
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CallbackQueryHandler(button_click))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, message_handler))

    # Запуск бота
    application.run_polling()
EOF

# Запуск xui бота
cat > /usr/local/bot-x-ui/start-x-ui-bot.sh <<EOF
#!/bin/bash
source /usr/local/bot-x-ui/xuibotenv/bin/activate
python /usr/local/bot-x-ui/x-ui-bot.py
EOF

# Даем права на выполнение скрипта
chmod +x /usr/local/bot-x-ui/start-x-ui-bot.sh

# Демон xui бота
cat > /etc/systemd/system/xuibot.service <<EOF
[Unit]
Description=XRay Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bot-x-ui/
ExecStart=/usr/local/bot-x-ui/start-x-ui-bot.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start xuibot.service
systemctl enable xuibot.service



