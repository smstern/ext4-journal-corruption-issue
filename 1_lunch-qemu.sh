#!/bin/bash

set -exu

if [ ! -f .configuration ]
then
    echo "Please use 0_setup.sh before"
    exit 1
fi

echo "Load setup data"
source .configuration

echo "Compile source code"
{
    cc -O0 -Wall -Werror -o mmap-memset mmap-memset.c
}

echo "Install binary and init script in boot image"
{
    mkdir "${MOUNT_PATH}"
    sudo mount -o loop "${IMAGE_BASESYSTEM}" "${MOUNT_PATH}"

    {
        sudo mkdir -p "${MOUNT_PATH}/corrupted-fs/"

        EXT4ISSUE="${MOUNT_PATH}/ext4-issue/"
        sudo mkdir -p "${EXT4ISSUE}"
        sudo cp 2_corrupt-ex4fs.sh 3_check-ext4fs.sh mmap-memset "${EXT4ISSUE}"
    }

    sudo umount "${MOUNT_PATH}"
    rmdir "${MOUNT_PATH}"
}

echo "Cleanup"
{
    rm mmap-memset
}

echo "Run Linux and brake ext4 fs"
{
    qemu-system-x86_64 \
        -kernel "${KERNEL_IMAGE}" \
        -drive file="${IMAGE_BASESYSTEM}",index=0,media=disk,format=raw \
        -drive file="${IMAGE_EXT4ISSUE}",index=1,media=disk,format=raw \
        -nographic \
        -append "console=ttyS0 root=/dev/sda single"
}
