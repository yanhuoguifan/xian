#ifndef _ASM_X86_LINKAGE_H
#define _ASM_X86_LINKAGE_H

#ifdef __ASSEMBLY__

#define GLOBAL(name)	\
	.globl name;	\
	name:

#endif /* __ASSEMBLY__ */

#endif /* _ASM_X86_LINKAGE_H */