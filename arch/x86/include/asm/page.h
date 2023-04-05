#ifndef _ASM_X86_PAGE_H
#define _ASM_X86_PAGE_H

#ifdef __KERNEL__

#include <asm/page_types.h>

#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))

#endif	/* __KERNEL__ */
#endif /* _ASM_X86_PAGE_H */