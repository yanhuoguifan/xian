#include "boot.h"

struct boot_params boot_params __attribute__((aligned(16)));

static void copy_boot_params(void){
    //压栈方式：从左到右，rax，rcx，rdx
    memcpy(&boot_params.hdr, &hdr, sizeof hdr);
}

void main(void){

    copy_boot_params();
    /* First, copy the boot header into the "zeropage" */


    if (multiboot_save() != 0) {
        return;
    }
    
}