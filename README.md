# macos-vpn-traffic-dns-split
Traffic and DNS split tunnelling for MacOS when using VPN

## Overview
TODO: more info

## dnsmasq setup

### Install

```sh
brew install dnsmasq
```

### Configure

```sh
cp dnsmasq.conf /usr/local/etc/dnsmasq.conf
```

## Network override setup

```sh
mkdir -p $HOME/.util/scripts
cp scripts/network-override.sh $HOME/.util/scripts/
```

```sh
cp agent/network-override.plist /Library/LaunchDaemons/
sudo launchctl load -w /Library/LaunchDaemons/network.watcher.plist
```

## Useful commands

### Check routes

```sh
watch -d "netstat -rn"
```

### Check for DNS leaks

```sh
sudo tcpdump -s0 -lvni utun2 'udp port 53'
sudo tcpdump -s0 -lvni lo0 'udp port 53'
sudo tcpdump -s0 -lvni en0 'udp port 53'
```
