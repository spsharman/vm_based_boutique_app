- path: /var/lib/cloud/scripts/per-once/resize_rootfs.sh
  owner: root:root
  permissions: '0744'
  content: |
    #! /bin/bash

    growpart /dev/sda 3
    pvresize /dev/sda3
    lvm lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
    resize2fs -p /dev/mapper/ubuntu--vg-ubuntu--lv