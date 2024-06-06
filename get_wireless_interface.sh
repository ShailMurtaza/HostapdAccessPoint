#!/usr/bin/bash

interfaces=($(iwconfig 2>&1 | grep "IEEE" | awk '{print $1;}'))
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
read -p "Wireless Interface: " choice

if [[ $choice -le 0 || $choice -gt ${#interfaces[@]} ]]; then
    echo "\033[31m [-] Invalid Choice \033[0m\n"
    exit 1
fi


i2="${interfaces[$((choice - 1))]}"
echo -e "\033[32m [+] SELECTED: $i2 \033[0m\n"

