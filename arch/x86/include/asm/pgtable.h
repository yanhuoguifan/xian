#ifndef _ASM_X86_PGTABLE_H
#define _ASM_X86_PGTABLE_H

#include <asm/pgtable_types.h>

#ifndef __ASSEMBLY__

#ifndef __PAGETABLE_PUD_FOLDED
#define pgd_clear(pgd)			native_pgd_clear(pgd)
#endif

#endif	/* __ASSEMBLY__ */

#ifdef CONFIG_X86_32
# include "pgtable_32.h"
#else
# include "pgtable_64.h"
#endif

#ifndef __ASSEMBLY__
#include <xian/mm_types.h>

#endif	/* __ASSEMBLY__ */

/*
 * the pgd page can be thought of an array like this: pgd_t[PTRS_PER_PGD]
 *
 * this macro returns the index of the entry in the pgd page which would
 * control the given virtual address
 */
#define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))


/*
 * pgd_offset() returns a (pgd_t *)
 * pgd_index() is used get the offset into the pgd page's array of pgd_t's;
 */
#define pgd_offset(mm, address) ((mm)->pgd + pgd_index((address)))
/*
 * a shortcut which implies the use of the kernel's pgd, instead
 * of a process's
 */
#define pgd_offset_k(address) pgd_offset(&init_mm, (address))


#endif /* _ASM_X86_PGTABLE_H */