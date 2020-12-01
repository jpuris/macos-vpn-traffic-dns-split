#!/bin/bash

# SETTINGS
dns="127.0.0.1"
gateway="A.A.A.A" # TODO: detect automatically
vpn_networks="B.B.B.0/24 C.C.C.0/24 D.D.0.0/16"

if [[ $EUID -ne 0 ]]; then
    echo "Run this as root"
    exit 1
fi

# If your utun interface tend to change like mine you can do the following given the right interface is the last one in the list
INTERFACE=$(ifconfig | grep -A1 utun | grep -B1 'inet ' | grep utun | cut -d : -f 1 | grep utun | tail -n 1)

# last line in the file is the gateway ip
route change default ${gateway}
for net in ${vpn_networks}; do route add -net ${net} -interface $INTERFACE; done;

# Update DNS in resolv.conf
cat <<EOF | sudo tee /etc/resolv.conf
nameserver ${dns}
EOF

# Update DNS in system db
states=$(scutil <<< list | awk '{ print $4 }' | egrep '^State:/Network/Service/[^/]+/DNS$')
while read state; do printf "d.init\nget ${state}\nd.add ServerAddresses * ${dns}\nset ${state}\nquit\n" | sudo scutil; done <<<"$states"

# Flush
sudo killall -HUP mDNSResponder
sudo dscacheutil -flushcache