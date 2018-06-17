#!/bin/bash

set -exu

# arguments
KERNEL_DIR=$1
KERNEL_IMAGE=$2

# const defines
CFGFILE=.configuration
BS_IMG=basesystem.img
EXT4_IMG=ext4_issue.img
MOUNT_PATH=mount-point.dir

echo "Create basesystem.img"
qemu-img create "${BS_IMG}" 1g
mkfs.ext2 "${BS_IMG}"
mkdir "${MOUNT_PATH}"
sudo mount -o loop "${BS_IMG}" "${MOUNT_PATH}"
sudo debootstrap --arch amd64 jessie "${MOUNT_PATH}"
sudo umount "${MOUNT_PATH}"
rmdir "${MOUNT_PATH}"

echo "Create ext4 issue partition"
qemu-img create "${EXT4_IMG}" 1g
mkfs.ext4 "${EXT4_IMG}"
mkdir "${MOUNT_PATH}"
sudo mount -o loop "${EXT4_IMG}" "${MOUNT_PATH}"
sudo umount "${MOUNT_PATH}"
rmdir "${MOUNT_PATH}"

echo "Save configuration"
{
    echo "# Generated from setup.sh"
    echo "KERNEL_DIR=${KERNEL_DIR}"
    echo "KERNEL_IMAGE=${KERNEL_IMAGE}"
    echo "IMAGE_BASESYSTEM=${BS_IMG}"
    echo "IMAGE_EXT4ISSUE=${EXT4_IMG}"
    echo "MOUNT_PATH=${MOUNT_PATH}"
} > "${CFGFILE}"

echo "Done"
