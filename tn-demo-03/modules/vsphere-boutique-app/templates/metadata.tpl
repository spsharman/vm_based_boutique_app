network:
  ethernets:
    ens160:
      addresses:
      - ${ipAddress}/${subnetBits}
      gateway4: ${gateway}
      nameservers:
        addresses:
        - ${nameserver}
        search:
        - ${domain}
  version: 2