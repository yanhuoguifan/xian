#!/bin/sh

sh_dir(){
    now_dir=$(pwd)
    cd $(dirname $0)
    sh_dir_name=$(pwd)
    cd ${now_dir}
    echo "${sh_dir_name}"
}

sudo qemu-system-x86_64 -hda xian.qcow2 -m 1000 -s -S  & 
path=$(pwd)
$(sh_dir $0)
gdb -x "$(sh_dir $0)/xian.gdb"