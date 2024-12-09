# XUI-REVERSE-PROXY ([Russian](/README_RU.md)) <img src="https://img.shields.io/github/stars/cortez24rus/xui-reverse-proxy?style=social" />
<p align="center"><a href="#"><img src="./media/3X-UI.png" alt="Image" ></a></p>

-----

### Proxy using VLESS-TCP-XTLS-Vision and VLESS-TCP-REALITY (Steal oneself) behind reverse-proxy NGINX
This script is designed to quickly and easily set up a hidden proxy server, with masking via NGINX. In this variant, all incoming requests are handled by NGINX, and the server acts as a proxy server only if the request contains the correct path (URI). This increases security and helps to hide the true purpose of the server.

> [!IMPORTANT]
>  This script has been tested in a KVM virtualization environment. You will need your own domain, which needs to be bound to Cloudflare for it to work correctly. It is recommended to run the script as root on a freshly installed system.

> [!NOTE]
> The script is configured according to routing rules for users in Russia.

### Supported Operating Systems:

| **Ubuntu**       | **Debian**        | **CentOS**       |
|------------------|-------------------|------------------|
| 24.04 LTS        | 12 (bookworm)     | Stream 9         |
| 22.04 LTS        | 11 (bullseye)     | Stream 8         |
| 20.04 LTS        | 10 (buster)       | 7                |

-----

### Setting up cloudflare
1. Upgrade the system and reboot the server.
2. Configure Cloudflare:
   - Bind your domain to Cloudflare.
   - Add the following DNS records:

| Type  | Name             | Content          | Proxy status  |
| ----- | ---------------- | ---------------- | ------------- |
| A     | your_domain_name | your_server_ip   | DNS only      |
| CNAME | www              | your_domain_name | DNS only      |
   
3. SSL/TLS settings in Cloudflare:
   - Go to SSL/TLS > Overview and select Full for the Configure option.
   - Set the Minimum TLS Version to TLS 1.3.
   - Enable TLS 1.3 (true) under Edge Certificates.

-----

### Includes:
  
1. Xray server configuration with 3X-UI:
   - VLESS-TCP-XTLS-Vision и VLESS-TCP-REALITY (Steal oneself).
   - Connection of subscription and JSON subscription for automatic configuration updates.
2. Configuring NGINX reverse proxy on port 443.
3. providing security:
   - Automatic system updates via unattended-upgrades.
4. Configuring Cloudflare SSL certificates with automatic updates to secure connections.
5. Configuring WARP to protect traffic.
6. Enabling BBR - improving the performance of TCP connections.
7. Configuring UFW (Uncomplicated Firewall) for access control.
8. Configuring SSH, to provide the minimum required security.
9. Disabling IPv6 to prevent possible vulnerabilities.
10. Encrypting DNS queries using systemd-resolved (DoT) or AdGuard Home (Dot, DoH).
11. Selecting a random website from an array to add an extra layer of privacy and complexity for traffic analysis.

-----

## Options

| Option                  | Description                                                       | Default                          |
|-------------------------|-------------------------------------------------------------------|----------------------------------|
| `-u, --utils <true|false>`       | Enable additional utilities                                        | `${defaults[utils]}`             |
| `-d, --dns <true|false>`         | Enable DNS encryption                                              | `${defaults[dns]}`               |
| `-a, --addu <true|false>`        | Enable user addition                                               | `${defaults[addu]}`              |
| `-r, --autoupd <true|false>`     | Enable automatic updates                                           | `${defaults[autoupd]}`           |
| `-b, --bbr <true|false>`         | Enable BBR (TCP Congestion Control)                                | `${defaults[bbr]}`               |
| `-i, --ipv6 <true|false>`        | Disable IPv6 support                                              | `${defaults[ipv6]}`              |
| `-w, --warp <true|false>`        | Enable Warp                                                       | `${defaults[warp]}`              |
| `-c, --cert <true|false>`        | Enable certificate issuance for domain                             | `${defaults[cert]}`              |
| `-m, --mon <true|false>`         | Enable monitoring services (e.g., node_exporter)                   | `${defaults[mon]}`               |
| `-n, --nginx <true|false>`       | Enable NGINX installation                                          | `${defaults[nginx]}`             |
| `-p, --panel <true|false>`       | Enable panel installation for user management                      | `${defaults[panel]}`             |
| `-f, --firewall <true|false>`    | Enable firewall configuration                                      | `${defaults[firewall]}`          |
| `-s, --ssh <true|false>`         | Enable SSH access                                                 | `${defaults[ssh]}`               |
| `-t, --tgbot <true|false>`       | Enable Telegram bot integration for user management                | `${defaults[tgbot]}`             |
| `-h, --help`                   | Display this help message                                           |                                  |

## Examples
To enable DNS encryption and automatic updates:


### Installation of XUI-RP:

To begin configuring the server, simply run the following command in a terminal:
```sh
bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install-server.sh)
```

### Selecting and installing a random template for the website:
```sh
bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-random-site.sh)
```

The script will then prompt you for the necessary configuration information:

![image](https://github.com/user-attachments/assets/dc60caee-1b01-40c9-a344-e0a67ebfc2ee)

### Note: 
- Once the configuration is complete, the script will display all the necessary links and login information for the XUI administration panel.
- All configurations can be modified as needed due to the flexibility of the settings.
Количество скачиваний: **<downloads_placeholder>**

## Stargazers over time
[![Stargazers over time](https://starchart.cc/cortez24rus/xui-reverse-proxy.svg?variant=adaptive)](https://starchart.cc/cortez24rus/xui-reverse-proxy)
