- path: /var/lib/cloud/scripts/per-boot/runcmd.sh
  owner: root:root
  permissions: '0744'
  content: |
    #! /bin/bash

    docker compose -f /var/lib/cloud/scripts/per-boot/docker-compose.yml up -d

    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
      -keyout /tmp/boutique.key -out /tmp/boutique.crt \
      -subj /C=GB/ST=Middlesex/L=Bedfont/O=${customerName}/OU=hackathon/CN=*.${domain}

