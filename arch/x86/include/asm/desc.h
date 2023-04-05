#ifndef _ASM_X86_DESC_H
#define _ASM_X86_DESC_H

#include <asm/desc_defs.h>
#include <asm/segment.h>
#include <asm/page.h>
#include <xian/percpu-def.h>

//gdt表结构体
struct gdt_page {
	struct desc_struct gdt[GDT_ENTRIES];
} __attribute__((aligned(PAGE_SIZE)));
DECLARE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page);

#endif /* _ASM_X86_DESC_H */