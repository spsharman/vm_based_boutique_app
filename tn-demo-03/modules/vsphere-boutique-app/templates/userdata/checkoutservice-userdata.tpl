#cloud-config
fqdn: ${boutique_app_service}.${domain}

groups:
  - rwhitear

users:
  - name: rwhitear
    gecos: Russ Whitear
    primary_group: rwhitear
    groups: users, admin, adm
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$Lq1TzIitylJy3ON$VxC.0z/0Ddszw78p3cWng.H1//0Zen.ofW68wF7X/85PH7CWc1FBVOzyJ8ttlBUOF7d/1XvPsrePlF9pWrWvc/
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkv0NtOeR4250oodCQ1LjCcmQjEt5Wc7mfMuexgPDu/ rwhitear@russ0ubuntu
  - name: ssharman
    gecos: Steve Sharman
    primary_group: ssharman
    groups: users, admin, adm
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$Lq1TzIitylJy3ON$VxC.0z/0Ddszw78p3cWng.H1//0Zen.ofW68wF7X/85PH7CWc1FBVOzyJ8ttlBUOF7d/1XvPsrePlF9pWrWvc/
    ssh_authorized_keys:
      - ssh-ed25519 $6$ftNTb8B6M4Z$CGjDu1QZEPlrCyL0JTM4eIDPC4/oUjAza7lbIQuXgnqjNRwAZlPuWuezbh5miHFtCyoCpdbiaDqFeY/5r9QzR0 ssharman@ssharman-jumphost

write_files:
${runcmdScript}

${resizeRootfs}

- path: /var/lib/cloud/scripts/per-boot/docker-compose.yml
  owner: root:root
  permissions: '0644'
  content: |
    version: "3.8"
    services:
      checkoutservice:
        image: rwhitear/showcase-checkoutservice:develop
        restart: always
        ports:
          - "5050:5050"
        environment:
          - PORT=5050
          - PRODUCT_CATALOG_SERVICE_ADDR=${productCatalogServiceAddr}:3550
          - SHIPPING_SERVICE_ADDR=${shippingServiceAddr}:50051
          - PAYMENT_SERVICE_ADDR=${paymentServiceAddr}:50051
          - EMAIL_SERVICE_ADDR=${emailServiceAddr}:5000
          - CURRENCY_SERVICE_ADDR=${currencyServiceAddr}:7000
          - CART_SERVICE_ADDR=${cartServiceAddr}:7070

runcmd:
  - [ sh, "/var/lib/cloud/scripts/per-once/resize_rootfs.sh" ]

