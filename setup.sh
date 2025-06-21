#!/bin/bash

# install inotify-tools is required for file watching.
apt install -y inotify-tools

# copy the filewatcher.sh script to /usr/local/bin/
cp filewatcher.sh /usr/local/bin/
chmod +x /usr/local/bin/filewatcher.sh

mkdir -p /etc/filewatcher

