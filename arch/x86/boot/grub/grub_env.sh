#!/bin/sh
img_path=${1}
kernel_path=${2}
img_mount_path=${3}

format_fs(){
	if [ ! -d "${img_mount_path}" ]; 
	then
		mkdir "${img_mount_path}"
	else
		sudo umount "${img_mount_path}"
	fi

	if [ ! -e "${img_path}" ]; 
	then
		dd if=/dev/zero of="${img_path}" bs=1k count=8k
	else
		mount -t ext2 "${img_path}" "${img_mount_path}"
		exist_fs=$?
		if [ "${exist_fs}" -eq 1 ]
		then
			return
		fi
	fi

#到这里，一定是磁盘文件已经创建出来并且没有被格式化
#下面格式化文件系统并使用grub初始化
	losetup_device=$(sudo losetup -f)
	sudo losetup "$losetup_device" "${img_path}"
	sudo mkfs -q  -t ext2  "$losetup_device"
	sudo mount -o loop "${img_path}" "${img_mount_path}"
	sudo mkdir "${img_mount_path}/boot"
	sudo grub-install --boot-directory="${img_mount_path}/boot" --force --allow-floppy $losetup_device
}

cp_kernel(){
	sudo cp "${kernel_path}" "${img_mount_path}/boot/kernel"
	if [ -e "${img_mount_path}/boot/grub/grub.cfg" ]
	then
		src_cfg_mod_time=$(stat -c %Y arch/x86/boot/grub/grub.cfg)
		cfg_mod_time=$(stat -c %Y "${img_mount_path}/boot/grub/grub.cfg")
		if [ "${src_cfg_mod_time}" -eq "${cfg_mod_time}" ]
		then
			return
		fi
	fi
	sudo cp "arch/x86/boot/grub/grub.cfg" "${img_mount_path}/boot/grub/grub.cfg"
}

install_kernel(){
	format_fs
	cp_kernel
}

install_kernel 

