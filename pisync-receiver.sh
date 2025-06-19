#!/bin/bash


DEST_PATH="/etc/pihole/custom.list"
SOURCE_PATH="/home/pisync/custom.list"

cp -f $SOURCE_PATH $DEST_PATH
