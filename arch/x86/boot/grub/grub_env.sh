#!/bin/sh
img_path=${1}
set_up_path0=${2}
set_up_path1=${3}
kernel_path=${4}
img_mount_path=${5}

format_fs(){
	if [ ! -d "${img_mount_path}" ]; 
	then
		mkdir "${img_mount_path}"
	fi

	if [ ! -e "${img_path}.raw" ]; 
	then
		dd if=/dev/zero of="${img_path}.raw" bs=1k count=8k
	else
		exist_fs=$(sudo mount | grep "${img_mount_path}")
		if [ -n "${exist_fs}"  ] && [ -d "${img_mount_path}/boot" ]
		then
			return
		fi
	fi

#到这里，一定是磁盘文件已经创建出来并且没有被格式化
#下面格式化文件系统并使用grub初始化
	losetup_device=$(sudo losetup -f)
	sudo losetup "$losetup_device" "${img_path}.raw"
	sudo mkfs -q  -t ext2  "$losetup_device"
	sudo mount -o loop "${img_path}.raw" "${img_mount_path}" || true
	sudo mkdir "${img_mount_path}/boot"
	sudo grub-install --boot-directory="${img_mount_path}/boot" --force --allow-floppy $losetup_device
}

cp_kernel(){
	sudo cp "${set_up_path0}" "${img_mount_path}/boot/setup0"
	sudo cp "${set_up_path1}" "${img_mount_path}/boot/setup1"
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

convert_img(){
	#因为挂载的文件无法被使用，先卸载，转成qcow2文件后再挂载
	sudo umount "${img_mount_path}"
	qemu-img convert -f raw -O qcow2 "${img_path}.raw" "${img_path}.qcow2"
	sudo mount -o loop "${img_path}.raw" "${img_mount_path}" || true
}

install_kernel(){
	format_fs
	cp_kernel
	convert_img
}

install_kernel 

