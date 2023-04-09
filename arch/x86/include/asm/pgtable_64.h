#ifndef _ASM_X86_PGTABLE_64_H
#define _ASM_X86_PGTABLE_64_H

#include <asm/pgtable_64_types.h>

#ifndef __ASSEMBLY__

extern pgd_t init_level4_pgt[];

#define swapper_pg_dir init_level4_pgt

static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)
{
	*pgdp = pgd;
}

static inline void native_pgd_clear(pgd_t *pgd)
{
	native_set_pgd(pgd, native_make_pgd(0));
}

#endif /* !__ASSEMBLY__ */

#endif /* _ASM_X86_PGTABLE_64_H */