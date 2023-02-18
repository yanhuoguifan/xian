#ifndef BOOT_BOOT_H
#define BOOT_BOOT_H

#define STACK_SIZE	512	/* Minimum number of bytes for stack */

#include <asm/multiboot.h>

#ifndef __ASSEMBLY__

#include <stdarg.h>
#include <xian/types.h>
#include <asm/setup.h>
#include "ctype.h"

extern struct setup_header hdr;
extern struct boot_params boot_params;
extern struct multiboot_tag_mmap *multiboot_tag_mmap;

/* Basic port I/O */
static inline void outb(u8 v, u16 port)
{
	asm volatile("outb %0,%1" : : "a" (v), "dN" (port));
}

/*multiboot_parse.c*/
int multiboot_save (void);

/* copy.S */
void *memcpy(void *dst, void *src, size_t len);

//如果gcc有内置的memcpy，使用gcc的memcpy
#define memcpy(d,s,l) __builtin_memcpy(d,s,l)

/* header.S */
void __attribute__((noreturn)) die(void);

/* memory.c */
int detect_memory(void);

/* cm.c */
void __attribute__((noreturn)) go_to_change_mode(void);

/* cmjump.S */
void __attribute__((noreturn))
	change_mode_jump(u32 entrypoint);

/* printf.c */
int vsprintf(char *buf, const char *fmt, va_list args);
int printf(const char *fmt, ...);

/* string.c */
size_t strnlen(const char *s, size_t maxlen);

/* tty.c */
void puts(const char *);
void putchar(int);

#endif /* __ASSEMBLY__ */

#endif /* BOOT_BOOT_H */