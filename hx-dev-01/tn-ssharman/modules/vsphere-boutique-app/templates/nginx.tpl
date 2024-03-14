- path: /var/lib/cloud/scripts/per-once/nginx.sh
  owner: root:root
  permissions: '0744'
  content: |
    #! /bin/bash

    docker cp /tmp/boutique.key NGINX:/etc/ssl/private/boutique.key
    docker cp /tmp/boutique.crt NGINX:/etc/ssl/certs/boutique.crt
    docker cp /tmp/nginx-boutique.conf NGINX:/etc/nginx/conf.d/default.conf
    docker exec NGINX nginx -t
    docker exec NGINX nginx -s reload
    docker restart NGINX