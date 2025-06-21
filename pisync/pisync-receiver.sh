#!/bin/bash


DEST_PATH="/etc/pihole/hosts/custom.list"
SOURCE_PATH="/opt/pisync/custom.list"


if [ -f $SOURCE_PATH ]; then
    cp -f $SOURCE_PATH $DEST_PATH
fi
