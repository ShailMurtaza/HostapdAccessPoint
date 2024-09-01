#!/usr/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo -e "\033[31m [-] Require Root Access \033[0m" 1>&2
    exec sudo "$0" "$@"
fi

source ./get_interface.sh
source ./get_wireless_interface.sh
sed -i "s/^interface=.*$/interface=$i2/" "dnsmasq.conf"
sed -i "s/^interface=.*$/interface=$i2/" "hostapd.conf"

# Setup the interface
nmcli dev set $i2 managed no
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
tmux new-session \; \
    split-window -v \; \
    send-keys "sudo killall dnsmasq ; sudo dnsmasq -C dnsmasq.conf -d; echo 'Stopped ...'; read" C-m \; \
    select-pane -t 0 \; \
    send-keys "sudo hostapd hostapd.conf; echo 'Stopped ...'; read" C-m

