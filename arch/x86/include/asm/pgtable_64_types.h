#ifndef _ASM_X86_PGTABLE_64_DEFS_H
#define _ASM_X86_PGTABLE_64_DEFS_H

#ifndef __ASSEMBLY__

/*
 * These are used to make use of C type-checking..
 */
typedef unsigned long	pteval_t;

#endif	/* !__ASSEMBLY__ */

/*
 * PGDIR_SHIFT determines what a top-level page table entry can map
 */
#define PGDIR_SHIFT	39
#define PTRS_PER_PGD	512

/*
 * 3rd level page
 */
#define PUD_SHIFT	30
#define PTRS_PER_PUD	512

/*
 * PMD_SHIFT determines the size of the area a middle-level
 * page table can map
 */
#define PMD_SHIFT	21
#define PTRS_PER_PMD	512

//2M
#define PMD_SIZE	(_AC(1, UL) << PMD_SHIFT)
#define PMD_MASK	(~(PMD_SIZE - 1))
//256G
#define PGDIR_SIZE	(_AC(1, UL) << PGDIR_SHIFT)

#endif /* _ASM_X86_PGTABLE_64_DEFS_H */