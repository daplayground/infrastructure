#!/bin/bash

# mkdir ./ssh_keys
# ssh-keygen -t ed25519 -a 100 -f ./ssh_keys/id_ed25519
# ssh-keygen -t rsa -b 4096 -C "" -f ./ssh_keys/id_rsa

# ansible-galaxy collection install community.kubernetes

RASPBERRY_PI_1=192.168.1.140
RASPBERRY_PI_2=192.168.1.137
RASPBERRY_PI_3=192.168.1.138
USERNAME=alejandro

# List of Raspberry Pi IP addresses
RASPBERRY_PIS=("${RASPBERRY_PI_1}" "${RASPBERRY_PI_2}" "${RASPBERRY_PI_3}")

# For each Raspberry Pi
for IP_ADDRESS in "${RASPBERRY_PIS[@]}"
do
    # Copy the public key to the Raspberry Pi
    cat ./ssh_keys/id_rsa.pub | ssh "${USERNAME}@${IP_ADDRESS}" 'mkdir -p ~/.ssh && cat > ~/.ssh/authorized_keys'
done
