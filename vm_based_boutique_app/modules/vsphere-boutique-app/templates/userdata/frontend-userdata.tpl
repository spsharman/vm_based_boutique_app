#cloud-config
fqdn: ${boutique_app_service}.${domain}

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
        image: rwhitear/showcase-frontend:vertical15
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