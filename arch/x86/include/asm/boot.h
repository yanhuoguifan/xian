#ifndef _ASM_X86_BOOT_H
#define _ASM_X86_BOOT_H

#ifdef __KERNEL__

/* Physical address where kernel should be loaded. */
#define LOAD_PHYSICAL_ADDR ((CONFIG_PHYSICAL_START \
				+ (CONFIG_PHYSICAL_ALIGN - 1)) \
				& ~(CONFIG_PHYSICAL_ALIGN - 1))

#define BOOT_HEAP_SIZE	0x8000

#ifdef CONFIG_X86_64
#define BOOT_STACK_SIZE	0x4000
#else
#define BOOT_STACK_SIZE	0x1000
#endif

#endif /* __KERNEL__ */

#endif /* _ASM_X86_BOOT_H */