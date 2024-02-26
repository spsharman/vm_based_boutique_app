#cloud-config
fqdn: ${boutique_app_service}.${domain}

groups:
  - user-01
  - user-02

users:
  - name: user-01
    gecos: user-01
    primary_group: user-01
    groups: users, admin, adm
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$Lq1TzIitylJy3ON$VxC.0z/0Ddszw78p3cWng.H1//0Zen.ofW68wF7X/85PH7CWc1FBVOzyJ8ttlBUOF7d/1XvPsrePlF9pWrWvc/
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkv0NtOeR4250oodCQ1LjCcmQjEt5Wc7mfMuexgPDu/ user-01@ubuntu
  - name: user-02
    gecos: user-02
    primary_group: user-02
    groups: users, admin, adm
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$Lq1TzIitylJy3ON$VxC.0z/0Ddszw78p3cWng.H1//0Zen.ofW68wF7X/85PH7CWc1FBVOzyJ8ttlBUOF7d/1XvPsrePlF9pWrWvc/
    ssh_authorized_keys:
      - ssh-ed25519 $6$ftNTb8B6M4Z$CGjDu1QZEPlrCyL0JTM4eIDPC4/oUjAza7lbIQuXgnqjNRwAZlPuWuezbh5miHFtCyoCpdbiaDqFeY/5r9QzR0 user-02@ubuntu

write_files:
${runcmdScript}

${resizeRootfs}

${nginxScript}

- path: /var/lib/cloud/scripts/per-boot/docker-compose.yml
  owner: root:root
  permissions: '0644'
  content: |
    version: "3.8"
    services:
      frontend:
        image: user-01/showcase-frontend:vertical15
        restart: always
        networks:
          - boutique
        ports:
          - "8080:8080"
        environment:
          - PORT=8080
          - PRODUCT_CATALOG_SERVICE_ADDR=${productCatalogServiceAddr}:3550
          - CURRENCY_SERVICE_ADDR=${currencyServiceAddr}:7000
          - CART_SERVICE_ADDR=${cartServiceAddr}:7070
          - RECOMMENDATION_SERVICE_ADDR=${recommendationServiceAddr}:8080
          - SHIPPING_SERVICE_ADDR=${shippingServiceAddr}:50051
          - CHECKOUT_SERVICE_ADDR=${checkoutServiceAddr}:5050
          - AD_SERVICE_ADDR=${adServiceAddr}:9555
          - ENV_PLATFORM=${envPlatform}
          - CUSTOMER_NAME=${customerName}

      nginx:
        image: nginx:latest
        container_name: NGINX
        restart: always
        networks:
          - boutique
        ports:
          - 80:80
          - 443:443

    networks:
      boutique:
        name: boutique

- path: /tmp/nginx-boutique.conf
  owner: root:root
  permissions: '0644'
  content: |
    server {
      listen [::]:443 ssl ipv6only=off;

      # CHANGE THIS TO YOUR SERVER'S NAME
      server_name ${boutique_app_service}.${domain};

      ssl_certificate /etc/ssl/certs/boutique.crt;
      ssl_certificate_key /etc/ssl/private/boutique.key;

      client_max_body_size 25m;

      location / {
          # proxy_pass http://127.0.0.1:8080;
          proxy_pass http://frontend:8080;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
      }
    }

    server {
      # Redirect HTTP traffic to HTTPS
      listen [::]:80 ipv6only=off;
      server_name _;
      return 301 https://$host$request_uri;
    }

runcmd:
  - [ sh, "/var/lib/cloud/scripts/per-once/resize_rootfs.sh" ]
  - [ sh, "/var/lib/cloud/scripts/per-once/nginx.sh" ]