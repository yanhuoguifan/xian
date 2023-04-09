/*
 *  prepare to run common code
 *
 *  Copyright (C) 2000 Andrea Arcangeli <andrea@suse.de> SuSE
 */

#include <xian/init.h>
#include <xian/kernel.h>
#include <xian/string.h>
#include <xian/start_kernel.h>

#include <asm/setup.h>
#include <asm/page.h>
#include <asm/pgtable.h>
#include <asm/tlbflush.h>
#include <asm/sections.h>

//清空四级页表第一项的恒等映射,即0-512G(往往只有前1G)虚拟空间
static void __init zap_identity_mappings(void)
{
	pgd_t *pgd = pgd_offset_k(0UL);
	pgd_clear(pgd);
	__flush_tlb_all();
}

/* Don't add a printk in there. printk relies on the PDA which is not initialized 
   yet. */
static void __init clear_bss(void)
{
	memset(__bss_start, 0,
	       (unsigned long) __bss_stop - (unsigned long) __bss_start);
}

static void __init copy_bootdata(char *real_mode_data)
{
	memcpy(&boot_params, real_mode_data, sizeof boot_params);
}

void __init x86_64_start_kernel(char * real_mode_data)
{   
    BUILD_BUG_ON((KERNEL_IMAGE_START & ~PMD_MASK) != 0);

    /* clear bss before set_intr_gate with early_idt_handler */
	clear_bss();

    /* Make NULL pointers segfault */
	zap_identity_mappings();

    x86_64_start_reservations(real_mode_data);
    //这里不应该return，不过即使return也会命中bad_address
}

void __init x86_64_start_reservations(char *real_mode_data)
{
    copy_bootdata(__va(real_mode_data));

    start_kernel();
}