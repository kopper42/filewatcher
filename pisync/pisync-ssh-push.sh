#!/bin/bash


LOCAL_FILE="/etc/pihole/hosts/custom.list"
SCP_SERVER="172.16.0.250"
SCP_PATH="/opt/pisync/custom.list"
SCP_USER="pisync"
SCP_CERT="/opt/pisync/.ssh/id_rsa_service"


scp -q -i $SCP_CERT $LOCAL_FILE $SCP_USER@$SCP_SERVER:$SCP_PATH
#scp -q $LOCAL_FILE $SCP_USER@$SCP_SERVER:$SCP_PATH
if [ $? -ne 0 ]; then
    echo "Error: SCP failed to copy $LOCAL_FILE to $SCP_SERVER" >&2
    # Decide what to do on error - exit, log, or continue with alternative action
    exit 1
else
    echo "Successfully copied $LOCAL_FILE to $SCP_SERVER"
fi
