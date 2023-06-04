#ifndef _ASM_X86_TLBFLUSH_H
#define _ASM_X86_TLBFLUSH_H

#include <asm/system.h>

#define __flush_tlb() __native_flush_tlb()
#define __flush_tlb_global() __native_flush_tlb_global()

static inline void __native_flush_tlb(void)
{
	native_write_cr3(native_read_cr3());
}

static inline void __native_flush_tlb_global(void)
{
}

static inline void __flush_tlb_all(void)
{
	if (0)
		__flush_tlb_global();
	else
		__flush_tlb();
}

#endif /* _ASM_X86_TLBFLUSH_H */