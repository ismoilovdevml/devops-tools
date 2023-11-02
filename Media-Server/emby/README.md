## Install and Configure **emby** media server

### Install

**Ubuntu X64**
```bash
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/4.7.14.0/emby-server-deb_4.7.14.0_amd64.deb
sudo dpkg -i emby-server-deb_4.7.14.0_amd64.deb
```

**Debian X64**

```bash
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/4.7.14.0/emby-server-deb_4.7.14.0_amd64.deb
sudo dpkg -i emby-server-deb_4.7.14.0_amd64.deb
```
**Arch Linux**

```bash
pacman -S emby-server
```
**CentOS X64**

```bash
yum install https://github.com/MediaBrowser/Emby.Releases/releases/download/4.7.14.0/emby-server-rpm_4.7.14.0_x86_64.rpm
```

### Nginx configration

```conf
server {
    server_name emby-server.uz www.emby-server.uz;

    location / {
        proxy_pass http://localhost:8096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
server {
    if ($host = emby-server.uz) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name emby-server.uz www.emby-server.uz;
    return 404; # managed by Certbot


}
```

### Free SSL 

```bash
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d emby-server.uz
sudo certbot renew --dry-run
sudo systemctl reload nginx
```