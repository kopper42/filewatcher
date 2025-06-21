#!/bin/bash


DEST_PATH="/etc/pihole/hosts/custom.list"
SOURCE_PATH="/opt/pisync/custom.list"

cp -f $SOURCE_PATH $DEST_PATH
