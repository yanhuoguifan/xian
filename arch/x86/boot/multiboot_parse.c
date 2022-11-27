#include "boot.h"

int multiboot_save () {
    if (boot_params.hdr.multiboot_magic != MULTIBOOT_BOOTLOADER_MAGIC) {
        printf ("Invalid magic number: 0x%x\n", (unsigned) boot_params.hdr.multiboot_magic);
        return -1;
    }

    return 0;
}