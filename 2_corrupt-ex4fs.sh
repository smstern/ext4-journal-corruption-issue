#!/bin/bash

set -exu

echo "Mount /dev/sdb ..."
mount -t ext4 -o defaults,data=journal /dev/sdb /corrupted-fs
chmod -R 777 /corrupted-fs

echo "Start filesystem killer..."
su - nobody -s /bin/bash -c /ext4-issue/mmap-memset &

echo "Wait a bit for journal to happen ..."
sleep 25

echo "Trigger a crash, to kill the filesystem via journal"
echo c | tee /proc/sysrq-trigger
