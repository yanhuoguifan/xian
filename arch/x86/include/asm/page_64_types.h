#ifndef _ASM_X86_PAGE_64_DEFS_H
#define _ASM_X86_PAGE_64_DEFS_H

#define THREAD_ORDER	1
#define THREAD_SIZE  (PAGE_SIZE << THREAD_ORDER)

/*
 * Set __PAGE_OFFSET to the most negative possible address +
 * PGDIR_SIZE*16 (pgd slot 272).  The gap is to allow a space for a
 * hypervisor to fit.  Choosing 16 slots here is arbitrary, but it's
 * what Xen requires.
 * 这里开始的1G虚拟地址映射到物理地址前1G
 */
#define __PAGE_OFFSET           _AC(0xffff880000000000, UL)

#define __PHYSICAL_START	((CONFIG_PHYSICAL_START +	 	\
				  (CONFIG_PHYSICAL_ALIGN - 1)) &	\
				 ~(CONFIG_PHYSICAL_ALIGN - 1))

#define __START_KERNEL		(__START_KERNEL_map + __PHYSICAL_START)
//0xffffffff80000000 ->前面是33个1，但实际前16个没有意义
#define __START_KERNEL_map	_AC(0xffffffff80000000, UL)

/*
 * Kernel image size is limited to 512 MB (see level2_kernel_pgt in
 * arch/x86/kernel/head_64.S), and it is mapped here:
 */
#define KERNEL_IMAGE_SIZE	(512 * 1024 * 1024)
#define KERNEL_IMAGE_START	_AC(0xffffffff80000000, UL)

#endif /* _ASM_X86_PAGE_64_DEFS_H */