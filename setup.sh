#!/bin/bash

# copy the filewatcher service file to /etc/systemd/system/
cp filewatcher.service /etc/systemd/system/ 

# copy the filewatcher.sh script to /usr/local/bin/
cp filewatcher.sh /usr/local/bin/

# Reload the systemd daemon
systemctl daemon-reload

