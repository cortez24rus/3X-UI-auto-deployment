[RUSSIAN](/README_RU.md)
<p align="center"><a href="#"><img src="./media/3X-UI.png" alt="Image"></a></p>

# XUI-REVERSE-PROXY

-----

### Proxy using Trojan and VLESS (Reality) protocols behind NGINX reverse-proxy
This script is intended for quick and easy configuration of a hidden proxy server using Trojan TLS and VLESS (Reality) protocols, with masking through NGINX. In this variant, all incoming requests are processed by NGINX and the server acts as a proxy server only if the request contains the correct path (URI). This increases security and helps hide the true purpose of the server.

> [!IMPORTANT]
>  This script has been tested on Debian 12 in a KVM virtualization environment. You will need your own domain, which needs to be bound to Cloudflare for it to work correctly. It is recommended to run the script as root on a freshly installed system.

> [!NOTE]
> The script is configured according to routing rules for users in Russia.

### Setting up cloudflare
1. Upgrade the system and reboot the server.
2. Configure Cloudflare:
   - Bind your domain to Cloudflare.
   - Add the following DNS records:

| Type  | Name             | Content          | Proxy status  |
| ----- | ---------------- | ---------------- | ------------- |
| A     | your_domain_name | your_server_ip   | Proxied       |
| CNAME | www              | your_domain_name | DNS only      |
   
3. SSL/TLS settings in Cloudflare:
   - Go to SSL/TLS > Overview and select Full for the Configure option.
   - Set the Minimum TLS Version to TLS 1.3.
   - Enable TLS 1.3 (true) under Edge Certificates.

-----

### Includes:
  
1. 3X-UI Xray server configuration:
   - Trojan TLS and VLESS Reality protocols.
   - Connection of subscription and JSON subscription for automatic configuration updates.
2. Configuring NGINX reverse proxy on port 443.
3. providing security:
   - Automatic system updates via unattended-upgrades.
4. Configuring Cloudflare SSL certificates with automatic updates to secure connections.
5. Configuring WARP to protect traffic.
6. Enabling BBR - improving the performance of TCP connections.
7. Configuring UFW (Uncomplicated Firewall) for access control.
8. Configuring SSH, to provide minimal security.
9. Disabling IPv6 to prevent possible vulnerabilities.
10. Encrypt DNS queries using systemd-resolved or AdGuard Home (DNS over TLS or DNS over HTTPS).

-----

### Usage:

To begin configuring the server, simply run the following command in a terminal:
```sh
bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install.sh)
```

### Tg-bot:

In order to install a bot on the server, it is enough to configure the launch of the base script with the -bot switch:
```sh
bash <(curl -Ls https://github.com/cortez24rus/xui-reverse-proxy/raw/refs/heads/main/xui-rp-install.sh) -bot
```

The script will then prompt you for the necessary configuration information:

![image](https://github.com/user-attachments/assets/dc60caee-1b01-40c9-a344-e0a67ebfc2ee)

### Note: 
- Once the configuration is complete, the script will display all the necessary links and login information for the XUI administration panel.
- All configurations will be able to be modified as needed due to the flexibility of the settings.
