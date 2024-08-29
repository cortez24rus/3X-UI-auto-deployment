# 3X-UI-XRAY-NGINX

### Прокси с использованием протоколов Trojan и VLESS (Reality) за реверс-прокси NGINX
Данный скрипт предназначен для полной настройки скрытого прокси-сервера с маскировкой при помощи NGINX. При данном методе настройки все запросы к прокси принимает NGINX, а сервер работает как прокси только при наличии в запросе правильного пути.

> [!IMPORTANT]
> Рекомендуемая ОС: Debian 12 или Ubuntu 22.04/24.04, виртуализация — KVM. Для настройки понадобится свой домен, прикреплённый к аккаунту Cloudflare. Запускайте от имени root на свежеустановленной системе. Рекомендуется обновить систему и перезагрузить сервер перед запуском скрипта.
>
> Необходимо подключить домен к cloudflare, добавить DNS записи
> Type    Name          Content       Proxy status
> A       example.com   ip address    Proxied
> CNAME   www           example.com   DNS only
>
> SSL/TLS > Edge Cerificates > Minimum TLS Version (TLS 1.3)
>
> SSL/TLS > Edge Cerificates > TLS 1.3 (true) 

> [!NOTE]
> С правилами маршрутизации для России.

### Включает:
1) Настройку сервера 3X-UI Xray (протоколы Trojan Tls и VLESS Reality, подписка, json подписка)
2) Настройку обратного прокси NGINX на 443 порту
3) Настройку безопасности, включая автоматические обновления (unattended-upgrades)
4) SSL сертификаты Cloudflare с автоматическим обновлением
5) Настройку WARP
6) Включение BBR
7) Настройка UFW
8) Настройка SSH за NGINX
9) Отключение IPv6
10) Включение DNS over HTTPS 
 
### Использование:

Для настройки сервера запустите эту команду:

```
bash <(curl -Ls https://github.com/cortez24rus/3X-UI-auto-deployment/raw/main/3x-ui-server.sh)
```

Затем просто введите необходимую информацию:

![pic-ru](https://github.com/cortez24rus/3X-UI-auto-deployment/blob/main/Screenshot%20settings.png)

В конце скрипт покажет необходимые ссылки и данные для входа.
