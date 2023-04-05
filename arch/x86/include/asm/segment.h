#ifndef _ASM_X86_SEGMENT_H
#define _ASM_X86_SEGMENT_H

#ifdef CONFIG_X86_32

#define GDT_ENTRY_KERNEL_BASE		(12)

#define GDT_ENTRY_KERNEL_CS		(GDT_ENTRY_KERNEL_BASE+0)

#define GDT_ENTRY_KERNEL_DS		(GDT_ENTRY_KERNEL_BASE+1)

#define GDT_ENTRIES 32

#else

#define GDT_ENTRY_KERNEL32_CS 1
#define GDT_ENTRY_KERNEL_CS 2
#define GDT_ENTRY_KERNEL_DS 3

/*
 * we cannot use the same code segment descriptor for user and kernel
 * -- not even in the long flat mode, because of different DPL /kkeil
 * The segment offset needs to contain a RPL. Grr. -AK
 * GDT layout to get 64bit syscall right (sysret hardcodes gdt offsets)
 */
#define GDT_ENTRY_DEFAULT_USER32_CS 4
#define GDT_ENTRY_DEFAULT_USER_DS 5
#define GDT_ENTRY_DEFAULT_USER_CS 6

#define GDT_ENTRIES 16

#endif

#define __KERNEL_CS	(GDT_ENTRY_KERNEL_CS*8)
#define __KERNEL_DS	(GDT_ENTRY_KERNEL_DS*8)

#endif /* _ASM_X86_SEGMENT_H */