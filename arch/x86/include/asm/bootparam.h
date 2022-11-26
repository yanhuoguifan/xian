#ifndef _ASM_X86_BOOTPARAM_H
#define _ASM_X86_BOOTPARAM_H

#include <xian/types.h>

struct setup_header {
    __u32   multiboot_addr;
    __u32   multiboot_magic;
    __u32   heap_end_ptr;
} __attribute__((packed));

struct boot_params {
	struct setup_header hdr;    /* setup header */	
} __attribute__((packed));

#endif /* ! _ASM_X86_BOOTPARAM_H */