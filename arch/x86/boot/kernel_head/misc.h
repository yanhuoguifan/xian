#ifndef BOOT_MISC_H
#define BOOT_MISC_H

#ifdef CONFIG_X86_64
#define memptr long
#else
#define memptr unsigned
#endif


#ifndef __ASSEMBLY__

#include <asm/bootparam.h>
#include <xian/elf.h>
#include <asm/boot.h>

extern struct boot_params *real_mode;		/* Pointer to real-mode data */

//tty.c
void console_init(void);
void puts(const char *);

#endif //__ASSEMBLY__

#endif //BOOT_MISC_H