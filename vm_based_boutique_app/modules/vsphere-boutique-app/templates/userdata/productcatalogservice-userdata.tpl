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
      productcatalogservice:
        image: rwhitear/showcase-productcatalogservice:vertical15
        restart: always
        ports:
          - "3550:3550"
        environment:
          - PORT=3550

runcmd:
  - [ sh, "/var/lib/cloud/scripts/per-once/resize_rootfs.sh" ]


