#ifndef _ASM_X86_PGTABLE_H
#define _ASM_X86_PGTABLE_H

#include <asm/pgtable_types.h>

/*
 * the pgd page can be thought of an array like this: pgd_t[PTRS_PER_PGD]
 *
 * this macro returns the index of the entry in the pgd page which would
 * control the given virtual address
 */
#define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))

#endif /* _ASM_X86_PGTABLE_H */