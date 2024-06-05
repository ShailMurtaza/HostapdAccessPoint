#!/usr/bin/bash

interfaces=( $(ls /sys/class/net/) )
# Check if the array is empty
if [ ${#interfaces[@]} -eq 0 ]; then
    echo "[-] No interface found"
    exit 1
fi

i=1
for interface in "${interfaces[@]}"; do
    echo "$i) $interface"
    i=$((i + 1))
done
read -p "Interface with connection: " choice

if [[ $choice -le 0 || $choice -gt ${#interfaces[@]} ]]; then
    echo "[-] Invalid Choice"
    exit 1
fi


i1="${interfaces[$((choice - 1))]}"
echo -e "\033[32m[+] SELECTED: $i1\033[0m\n"
