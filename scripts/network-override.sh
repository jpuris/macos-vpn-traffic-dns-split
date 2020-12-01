#!/bin/bash

# SETTINGS
dns="127.0.0.1"
DNS_RESOLVE="127.0.0.1"
DNS="1.1.1.1 1.0.0.1"
GATEWAY="A.A.A.A" # CHANGE THIS! TODO: detect automatically
VPN_NETWORKS="B.B.B.0/24 C.C.C.0/24 D.D.0.0/16" # CHANGE THIS! 

if [[ $EUID -ne 0 ]]; then
    echo "Run this as root"
    exit 1
fi

# VPN Traffic split
# If your utun interface tend to change like mine you can do the following given the right interface is the last one in the list
INTERFACE=$(ifconfig | grep -A1 utun | grep -B1 'inet ' | grep utun | cut -d : -f 1 | grep utun | tail -n 1)

# last line in the file is the gateway ip
route change default ${GATEWAY}
for NET in ${VPN_NETWORKS}; do route add -net ${NET} -interface $INTERFACE; done;

# DNS
# Update DNS in resolv.conf
cat <<EOF | sudo tee /etc/resolv.conf
nameserver ${DNS_RESOLVE}
EOF

# Update DNS in system db
STATES=$(scutil <<< list | awk '{ print $4 }' | egrep '^State:/Network/Service/[^/]+/DNS$' | grep -v 'gpd.pan')
while read STATE; do printf "d.init\nget ${STATE}\nd.add ServerAddresses * ${DNS}\nset ${STATE}\nquit\n" | sudo scutil; done <<<"$STATES"

# Flush
sudo killall -HUP mDNSResponder
sudo dscacheutil -flushcache