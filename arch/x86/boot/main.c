#include "boot.h"

struct boot_params boot_params __attribute__((aligned(16)));

static void copy_boot_params(void){
    memcpy(&boot_params.hdr, &hdr, sizeof hdr);
}

void main(void){

    copy_boot_params();
    /* First, copy the boot header into the "zeropage" */
    if (boot_params.hdr.multiboot_magic != MULTIBOOT2_BOOTLOADER_MAGIC) {
        printf ("Invalid magic number: 0x\n", (unsigned) boot_params.hdr.multiboot_magic);
        return -1;
    }
    /*save message from multiboot*/
    if (multiboot_save() != 0) {
        puts("multiboot_save fail");
        die();
    }
    /* Detect memory layout */
    if (detect_memory() != 0) {
        puts("detect_memory fail");
        die();
    }
    /*save modules,include kernel and initrd*/
    if (save_modules() != 0) {
        puts("save_modules fail");
        die();
    }
    go_to_change_mode();
}