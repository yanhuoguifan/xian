#ifndef _ASM_X86_SEGMENT_H
#define _ASM_X86_SEGMENT_H

#ifdef CONFIG_X86_32

#define GDT_ENTRY_KERNEL_BASE		(12)

#define GDT_ENTRY_KERNEL_CS		(GDT_ENTRY_KERNEL_BASE+0)

#define GDT_ENTRY_KERNEL_DS		(GDT_ENTRY_KERNEL_BASE+1)

#else

#define GDT_ENTRY_KERNEL_CS 2
#define GDT_ENTRY_KERNEL_DS 3

#endif

#define __KERNEL_CS	(GDT_ENTRY_KERNEL_CS*8)
#define __KERNEL_DS	(GDT_ENTRY_KERNEL_DS*8)

#endif /* _ASM_X86_SEGMENT_H */