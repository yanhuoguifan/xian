#ifndef _ASM_X86_PROCESSOR_FLAGS_H
#define _ASM_X86_PROCESSOR_FLAGS_H
/* Various flags defined: can be included from assembler. */

/*
 * Basic CPU control in CR0
 */
#define X86_CR0_PE	0x00000001 /* Protection Enable */
#define X86_CR0_MP	0x00000002 /* Monitor Coprocessor */
#define X86_CR0_ET	0x00000010 /* Extension Type */
#define X86_CR0_NE	0x00000020 /* Numeric Error */
#define X86_CR0_WP	0x00010000 /* Write Protect */
#define X86_CR0_AM	0x00040000 /* Alignment Mask */
#define X86_CR0_PG	0x80000000 /* Paging */

/*
 * Intel CPU features in CR4
 */
#define X86_CR4_PAE	0x00000020 /* enable physical address extensions */
#define X86_CR4_PGE	0x00000080 /* enable global pages */

#endif /* _ASM_X86_PROCESSOR_FLAGS_H */