### Proxy using VLESS-TCP-XTLS-Vision and VLESS-TCP-REALITY (Steal oneself) behind reverse-proxy NGINX
This script is designed to quickly and easily set up a hidden proxy server, with masking via NGINX. In this variant, all incoming requests are handled by NGINX, and the server acts as a proxy server only if the request contains the correct path (URI). This increases security and helps to hide the true purpose of the server.

> [!IMPORTANT]
>  This script has been tested in a KVM virtualization environment. You will need your own domain, which needs to be bound to Cloudflare for it to work correctly. It is recommended to run the script as root on a freshly installed system.

### Общее количество просмотров за все время: 1
### Уникальные просмотры за все время: 2
### Общее количество просмотров за месяц: 1914
### Уникальные просмотры за месяц: 330