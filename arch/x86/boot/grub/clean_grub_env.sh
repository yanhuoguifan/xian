#!/bin/sh
img_path=${1}
img_mount_path=${2}

if [ -d "${img_mount_path}" ]
then
    sudo umount "${img_mount_path}"
    rm -rf "${img_mount_path}"
fi

if [ -e "${img_path}" ]
then
    rm "${img_path}"
fi