#ifndef _XIAN_MM_TYPES_H
#define _XIAN_MM_TYPES_H

#include <asm/page.h>
#include <asm/pgtable.h>

struct mm_struct {
    pgd_t * pgd;
};

extern struct   mm_struct init_mm;

#endif /* _XIAN_MM_TYPES_H */