#include <xian/mm_types.h>

#include <asm/pgtable.h>

struct mm_struct init_mm = {
	.pgd		= swapper_pg_dir,
};