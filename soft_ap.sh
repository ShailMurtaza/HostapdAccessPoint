#!/usr/bin/bash

source ./get_interface.sh
source ./get_wireless_interface.sh
sed -i "s/^interface=.*$/interface=$i2/" "dnsmasq.conf"
sed -i "s/^interface=.*$/interface=$i2/" "hostapd.conf"
exit

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

# start dnsmasq & hostapd
tmux split-window -v "sudo killall dnsmasq ; dnsmasq -C dnsmasq.conf -d ; echo 'Stopped ...'"
tmux split-window -h "sudo hostapd hostapd.conf ; echo 'Stopped ...'"
tmux select-pane -t 0

