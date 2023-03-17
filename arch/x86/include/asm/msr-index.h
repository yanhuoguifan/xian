#ifndef _ASM_X86_MSR_INDEX_H
#define _ASM_X86_MSR_INDEX_H

/* CPU model specific register (MSR) numbers */

/* x86-64 specific MSRs */
#define MSR_EFER		0xc0000080 /* extended feature register */

/* EFER bits: */
#define _EFER_LME		8  /* Long mode enable */

/* K7 MSRs */
#define MSR_K7_HWCR			0xc0010015

/* Intel defined MSRs. */
#define MSR_IA32_MISC_ENABLE		0x000001a0

#endif /* _ASM_X86_MSR_INDEX_H */