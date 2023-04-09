#ifndef _ASM_X86_TLBFLUSH_H
#define _ASM_X86_TLBFLUSH_H

#define __flush_tlb_global() __native_flush_tlb_global()

static inline void __native_flush_tlb_global(void)
{
}

static inline void __flush_tlb_all(void)
{
		__flush_tlb_global();
}

#endif /* _ASM_X86_TLBFLUSH_H */