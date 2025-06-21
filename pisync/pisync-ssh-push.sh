#!/bin/bash

## sudo useradd -r -s /sbin/nologin -c "PiSync Service User" -m -d /opt/pisync pisync
# sudo useradd -r -c "PiSync Service User" -m pisync
# ssh-keygen -t rsa -b 4096 -C "PiSync Service" -N "" -f /home/pisync/.ssh/id_rsa_service


LOCAL_FILE="/etc/pihole/hosts/custom.list"
SCP_SERVER="192.168.1.250"
SCP_PATH="/home/pisync/custom.list"
SCP_USER="pisync"
SCP_CERT="/home/pisync/.ssh/id_rsa_service"


scp -q -i $SCP_CERT $LOCAL_FILE $SCP_USER@$SCP_SERVER:$SCP_PATH
#scp -q $LOCAL_FILE $SCP_USER@$SCP_SERVER:$SCP_PATH
if [ $? -ne 0 ]; then
    echo "Error: SCP failed to copy $LOCAL_FILE to $SCP_SERVER" >&2
    # Decide what to do on error - exit, log, or continue with alternative action
    exit 1
else
    echo "Successfully copied $LOCAL_FILE to $SCP_SERVER"
fi
