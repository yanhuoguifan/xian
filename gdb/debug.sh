#!/bin/sh

sh_dir(){
    now_dir=$(pwd)
    cd $(dirname $0)
    sh_dir_name=$(pwd)
    cd ${now_dir}
    echo "${sh_dir_name}"
}

##当需要进入qemu monitor的时候，连接tcp的localhost:6666，比如nc localhost 6666

qemu-system-x86_64 -m 2048 -hda xian.qcow2  -monitor tcp:localhost:6666,server,nowait -s -S & 
gdb -x "$(sh_dir $0)/xian.gdb"