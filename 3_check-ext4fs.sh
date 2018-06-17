#!/bin/bash

set -exu

echo "Mount /dev/sdb ..."
mount -t ext4 -o defaults,data=journal /dev/sdb /corrupted-fs

echo "Dump dmesg | grep FS issues ..."
dmesg | grep -i "journal|EXT4|JBD"
