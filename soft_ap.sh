#!/usr/bin/bash

interface=($(iwconfig 2>&1 | grep "IEEE" | awk '{print $1;}'))

i1=enp0s3
i2=$interface
echo "Using $i2 as wireless interface"

# Setup the interface
ip link set $i2 down
ip addr flush dev $i2
ip link set $i2 up
ip addr add 10.0.0.1/24 dev $i2

# Create NAT
iptables -t nat -A POSTROUTING -o $i1 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $i1 -o $i2 -j ACCEPT
# sysctl -w net.ipv4.ip_forward=1
echo 1 > /proc/sys/net/ipv4/ip_forward

# start hostapd
xterm -e "sudo killall dnsmasq ; dnsmasq -C dnsmasq.conf -d ; echo 'Stopped ...' ; read" & disown
xterm -e "sudo hostapd hostapd.conf ; echo 'Stopped ...' ; read" & disown

