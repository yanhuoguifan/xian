#ifndef BOOT_BOOT_H
#define BOOT_BOOT_H

#define STACK_SIZE	512	/* Minimum number of bytes for stack */

#include <asm/multiboot.h>

#ifndef __ASSEMBLY__

#include <stdarg.h>
#include <asm/setup.h>
#include <xian/types.h>

extern struct setup_header hdr;
extern struct boot_params boot_params;

/*multiboot_parse.c*/
int multiboot_save (void);

/* copy.S */
void *memcpy(void *dst, void *src, size_t len);

//如果gcc有内置的memcpy，使用gcc的memcpy
#define memcpy(d,s,l) __builtin_memcpy(d,s,l)

/* printf.c */
int vsprintf(char *buf, const char *fmt, va_list args);
int printf(const char *fmt, ...);

#endif /* __ASSEMBLY__ */

#endif /* BOOT_BOOT_H */