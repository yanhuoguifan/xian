#ifndef _ASM_X86_PROCESSOR_FLAGS_H
#define _ASM_X86_PROCESSOR_FLAGS_H
/* Various flags defined: can be included from assembler. */

/*
 * Basic CPU control in CR0
 */
#define X86_CR0_PE	0x00000001 /* Protection Enable */
#define X86_CR0_PG	0x80000000 /* Paging */

/*
 * Intel CPU features in CR4
 */
#define X86_CR4_PAE	0x00000020 /* enable physical address extensions */

#endif /* _ASM_X86_PROCESSOR_FLAGS_H */