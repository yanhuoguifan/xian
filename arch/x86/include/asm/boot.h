#ifndef _ASM_X86_BOOT_H
#define _ASM_X86_BOOT_H

#ifdef __KERNEL__

#ifdef CONFIG_X86_64
#define BOOT_STACK_SIZE	0x4000
#else
#define BOOT_STACK_SIZE	0x1000
#endif

#endif /* __KERNEL__ */

#endif /* _ASM_X86_BOOT_H */