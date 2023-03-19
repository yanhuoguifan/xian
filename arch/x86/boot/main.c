#include "boot.h"

struct boot_params boot_params __attribute__((aligned(16)));

static void copy_boot_params(void){
    memcpy(&boot_params.hdr, &hdr, sizeof hdr);
}

void main(void){

    void* setup1_entry;

    copy_boot_params();
    /* First, copy the boot header into the "zeropage" */
    if (boot_params.hdr.multiboot_magic != MULTIBOOT2_BOOTLOADER_MAGIC) {
        printf ("Invalid magic number: 0x\n", (unsigned) boot_params.hdr.multiboot_magic);
        return;
    }
    /*save message from multiboot*/
    if (multiboot_save() != 0) {
        puts("multiboot_save fail");
        return;
    }
    /* Detect memory layout */
    if (detect_memory() != 0) {
        puts("detect_memory fail");
        return;
    }
    /*save modules,include kernel and setup1*/
    if (save_modules() != 0) {
        puts("save_modules fail");
        return;
    }

    if (load_setup1(&setup1_entry) != 0) {
        puts("load_setup1 fail");
        return;
    }

    printf("jump to %d to setup1", setup1_entry);
    jump_setup1(setup1_entry, &boot_params);
}