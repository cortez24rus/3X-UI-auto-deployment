#!/bin/bash

# Пример использования токена
if [[ -z "$1" ]]; then
    echo "Токен не был передан"
    exit 1
fi

# Установка пакетов
apt-get update && apt-get install -y python3 python3-pip python3-venv

rm -rf /usr/local/xui-rp/xui-rp-bot.py
rm -rf /usr/local/xui-rp/xui-rp-env
rm -rf /etc/systemd/systemd/xui-rp-bot.service
systemctl disable xui-rp-bot.service >/dev/null
systemctl stop xui-rp-bot.service >/dev/null
systemctl daemon-reload >/dev/null

# Создание директорий и т.д...
mkdir -p /usr/local/xui-rp/
python3 -m venv /usr/local/xui-rp/xui-rp-env
source /usr/local/xui-rp/xui-rp-env/bin/activate
pip install requests
pip install python-telegram-bot
deactivate

# XUI бот
cat > /usr/local/xui-rp/xui-rp-bot.py <<EOF
import sqlite3
import json
import uuid
from telegram import InlineKeyboardButton, InlineKeyboardMarkup, Update
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackQueryHandler, ContextTypes, MessageHandler
from telegram.ext import filters
from datetime import datetime, timedelta

# Вводные данные
DB_PATH = '/etc/x-ui/x-ui.db'
BOT_TOKEN = '$1'
BOT_AID = $2
NAME_MENU = "🎛 $3 🎛"

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
    all_ids = get_all_ids()  # Предполагается, что эта функция возвращает все id и соответствующие настройки

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

        # Округляем до следующего часа
        next_hour = (datetime.now() + timedelta(hours=1)).replace(minute=0, second=0, microsecond=0)

        # Добавляем два дня к следующему часу
        expiry_time = int((next_hour + timedelta(days=2)).timestamp() * 1000)

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

        # Обновляем настройки в таблице inbounds
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(settings), id))
        conn.commit()

        # Добавляем нового клиента в таблицу client_traffics
        cursor.execute('''
            INSERT INTO client_traffics (inbound_id, enable, email, up, down, expiry_time, total, reset)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (id, 1, email, 0, 0, expiry_time, 0, 30))  # Замените значения по необходимости

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
        clients_to_remove = [client for client in settings['clients'] if client['subId'] == subId]
        settings['clients'] = [client for client in settings['clients'] if client['subId'] != subId]

        # Удаляем пользователей из client_traffics
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()

        # Удаляем записи из client_traffics по email
        for client in clients_to_remove:
            email = client['email']
            cursor.execute("DELETE FROM client_traffics WHERE email = ?", (email,))
        
        # Обновляем inbounds
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

    user_traffic = {}  # Используем словарь для хранения трафика пользователей

    # Обработка данных
    for inbound in inbounds:
        settings = json.loads(inbound['settings'])
        for client in settings.get('clients', []):
            sub_id = client.get('subId')
            email = client.get('email')
            if sub_id:
                # Запрос для получения трафика пользователя
                cursor.execute("SELECT up, down FROM client_traffics WHERE email = ?", (email,))
                traffic = cursor.fetchone()
                up_traffic = traffic[0] / (1024 ** 3) if traffic and traffic[0] is not None else 0  # в гигабайтах
                down_traffic = traffic[1] / (1024 ** 3) if traffic and traffic[1] is not None else 0  # в гигабайтах

                # Если sub_id уже есть в словаре, суммируем трафик
                if sub_id in user_traffic:
                    user_traffic[sub_id]['up'] += up_traffic
                    user_traffic[sub_id]['down'] += down_traffic
                else:
                    # Иначе добавляем нового пользователя в словарь
                    user_traffic[sub_id] = {
                        'up': up_traffic,
                        'down': down_traffic,
                        'subscription_link': f"🔗 {suburl}{sub_id}" if suburl else f"/{sub_id}"
                    }
    conn.close()  # Закрываем соединение после завершения всех операций

    # Форматируем вывод
    user_lines = []
    for sub_id, traffic_info in user_traffic.items():
        user_lines.append(f"👤 {sub_id} - 🔼 Up {traffic_info['up']:.2f} GB / 🔽 Down {traffic_info['down']:.2f} GB\n{traffic_info['subscription_link']}")

    return "\n\n".join(user_lines) if user_lines else "No users"

def calculate_total_traffic():
    connection = sqlite3.connect(DB_PATH)
    cursor = connection.cursor()

    cursor.execute("SELECT up, down FROM inbounds")
    total_up = total_down = 0

    for up, down in cursor.fetchall():
        total_up += up
        total_down += down

    connection.close()
    # Переводим значения в гигабайты
    total_up_gb = total_up / (1024 ** 3)
    total_down_gb = total_down / (1024 ** 3)

    return total_up_gb, total_down_gb

# Функция для обработки команды /start
async def start_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.message.from_user.id if update.message else update.callback_query.from_user.id

    # Проверяем, является ли пользователь администратором
    if user_id != BOT_AID:
        await (update.message.reply_text("Access denied") if update.message else update.callback_query.edit_message_text("Access denied"))
        return
    # Сразу открываем основное меню
    keyboard = [
        [InlineKeyboardButton("📬 Inbounds", callback_data='inbounds')],
        [InlineKeyboardButton("🫂 User menu", callback_data='user_menu')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    if update.message:
        await update.message.reply_text(NAME_MENU, reply_markup=reply_markup)
    else:
        await update.callback_query.edit_message_text(NAME_MENU, reply_markup=reply_markup)
        
# Функция для обработки нажатия кнопок
async def show_inbounds_menu(query):
    total_up, total_down = calculate_total_traffic()
    remarks = get_inbounds_remarks()
    if remarks:
        header = f"📬 Inbounds 📬\n🔼 Total Up {total_up:.2f} GB / 🔽 Total Down {total_down:.2f} GB\n"
        keyboard = [
            [InlineKeyboardButton(
                f"{remark} - {up / (1024 ** 3):.2f} GB / {down / (1024 ** 3):.2f} GB {'🟢' if enable == 1 else '⭕️'}",
                callback_data=f"select_{remark}"
            )]
            for remark, up, down, enable in remarks
        ]
        keyboard.append([InlineKeyboardButton("🔙 Return", callback_data='start_menu')])
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text(header, reply_markup=reply_markup)
    else:
        await query.edit_message_text("No inbounds available")

async def button_click(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    if query.from_user.id != BOT_AID:
        await query.answer("Access denied", show_alert=True)
        return

    if query.data == 'user_menu':
        await show_user_menu(query)

    elif query.data == 'show_users':
        users_info = get_users_info()
        keyboard = [
            [InlineKeyboardButton("🔙 Return", callback_data='user_menu')]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text(text=f"🚦 Traffic / 💵 Subscription\n\n{users_info}", reply_markup=reply_markup)

    elif query.data == 'inbounds':
        await show_inbounds_menu(query)

    elif query.data.startswith("select_"):
        remark = query.data.split("select_")[1]
        toggle_enable(remark)
        await show_inbounds_menu(query)

    elif query.data == 'start_menu':
        await start_menu(update, context)

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
        subId = query.data.split('_')[1]
        remove_user_from_all_ids(subId)
        users = get_all_users()
        await show_delete_user_menu(query, users)

    elif query.data == 'list_users':
        await list_users(update, context)

    elif query.data.startswith("toggle_"):
        await toggle_user_enable(update, context)    

from telegram import InlineKeyboardButton, InlineKeyboardMarkup

async def list_users(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    all_ids = get_all_ids()
    users_keyboard = []
    row = []
    seen_sub_ids = set()  # Множество для отслеживания уже добавленных subId

    for id, settings in all_ids:
        for client in settings.get('clients', []):
            sub_id = client.get('subId')
            enable_status = client.get('enable', False)
            emoji = "🟢" if enable_status else "⭕️"

            # Проверяем, был ли sub_id уже добавлен
            if sub_id not in seen_sub_ids:
                seen_sub_ids.add(sub_id)  # Добавляем sub_id в множество
                
                # Добавляем кнопку в строку
                row.append(InlineKeyboardButton(f"{sub_id} {emoji}", callback_data=f"toggle_{sub_id}"))
                
                # Если в строке 2 кнопки, добавляем ее в клавиатуру и очищаем
                if len(row) == 2:
                    users_keyboard.append(row)
                    row = []

    # Добавляем последнюю строку, если она не пуста
    if row:
        users_keyboard.append(row)

    # Кнопка возврата внизу
    users_keyboard.append([InlineKeyboardButton("🔙 Return", callback_data='user_menu')])

    reply_markup = InlineKeyboardMarkup(users_keyboard)
    await update.callback_query.edit_message_text("🔄 Switch User Status", reply_markup=reply_markup)


# Изменение состояния enable при нажатии на кнопку
async def toggle_user_enable(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    sub_id = update.callback_query.data.split("toggle_")[1]
    
    # Выводим subId для отладки
    print(f"Toggle request for subId: {sub_id}")

    connection = sqlite3.connect(DB_PATH)
    cursor = connection.cursor()

    # Получаем текущие настройки для subId
    cursor.execute("SELECT settings FROM inbounds WHERE id = ?", (sub_id,))
    result = cursor.fetchone()

    if result:
        settings = json.loads(result[0])
        found = False
        
        for client in settings['clients']:
            # Сравниваем subId для поиска
            if client['subId'] == sub_id:
                client['enable'] = not client['enable']  # Переключаем состояние enable
                found = True
                break
        
        if found:
            # Обновляем настройки в базе данных
            cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(settings), sub_id))
            connection.commit()
            await update.callback_query.answer(f"Статус пользователя {sub_id} изменен на {'включен' if client['enable'] else 'выключен'}")
        else:
            await update.callback_query.answer("Пользователь не найден в списке клиентов.")
    else:
        await update.callback_query.answer("Пользователь не найден в базе данных.")

    connection.close()
    
    # Обновляем список пользователей
    await list_users(update, context)

# Изменение состояния enable при нажатии на кнопку
async def toggle_user_enable(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    sub_id = update.callback_query.data.split("toggle_")[1]
    
    # Выводим subId для отладки
    print(f"Toggle request for subId: {sub_id}")

    connection = sqlite3.connect(DB_PATH)
    cursor = connection.cursor()

    # Получаем текущие настройки для subId
    cursor.execute("SELECT id, settings FROM inbounds")
    all_ids = cursor.fetchall()

    for id, settings_json in all_ids:
        settings = json.loads(settings_json)

        # Находим клиента с соответствующим subId
        for client in settings.get('clients', []):
            if client.get('subId') == sub_id:
                # Переключаем состояние enable
                client['enable'] = not client.get('enable', False)
                print(f"Toggling enable for subId: {sub_id} to {client['enable']}")

                # Обновляем настройки в базе данных
                cursor.execute("UPDATE inbounds SET settings = ? WHERE id = ?", (json.dumps(settings), id))
                connection.commit()
                break  # Выходим из цикла после изменения

    connection.close()

    # Обновляем меню пользователей
    await list_users(update, context)

async def show_user_menu(query):
    keyboard = [
        [InlineKeyboardButton("✅ Add user", callback_data='add_user')],
        [InlineKeyboardButton("❌ Delete user", callback_data='delete_user')],
        [InlineKeyboardButton("🔄 Switch User Status", callback_data='list_users')],
        [InlineKeyboardButton("🚦 Traffic / 💵 Subscription", callback_data='show_users')],
        [InlineKeyboardButton("🔙 Return", callback_data='start_menu')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await query.edit_message_text("🫂 User menu 🫂", reply_markup=reply_markup)

async def show_delete_user_menu(query, users):
    keyboard = []
    for i, user in enumerate(users):
        # Добавляем пользователей в две колонки
        if i % 2 == 0:
            keyboard.append([InlineKeyboardButton(user, callback_data=f'remove_{user}')])
        else:
            keyboard[-1].append(InlineKeyboardButton(user, callback_data=f'remove_{user}'))
    keyboard.append([InlineKeyboardButton("🔙 Return", callback_data='user_menu')])
    reply_markup = InlineKeyboardMarkup(keyboard)
    await query.edit_message_text("❌ Select the user to delete ❌", reply_markup=reply_markup)

async def message_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    action = context.user_data.get('action')
    if action == 'add_user':
        name = update.message.text
        add_user_to_all_ids(name)
        await update.message.reply_text(f"User {name} added")
        context.user_data['action'] = None

if __name__ == '__main__':
    application = ApplicationBuilder().token(BOT_TOKEN).build()

    # Регистрация обработчиков команд и сообщений
    application.add_handler(CommandHandler("start", start_menu))
    application.add_handler(CallbackQueryHandler(button_click))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, message_handler))

    # Запуск бота
    application.run_polling()
EOF

# Демон xui бота
cat > /etc/systemd/system/xui-rp-bot.service <<EOF
[Unit]
Description=Xui Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/xui-rp/
ExecStart=/usr/local/xui-rp/xui-rp-env/bin/python /usr/local/xui-rp/xui-rp-bot.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start xui-rp-bot.service
systemctl enable xui-rp-bot.service
