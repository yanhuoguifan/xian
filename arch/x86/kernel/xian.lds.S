/*
 * ld script for the x86 kernel
 *
 * Historic 32-bit version written by Martin Mares <mj@atrey.karlin.mff.cuni.cz>
 *
 * Modernisation, unification and other changes and fixes:
 *   Copyright (C) 2007-2009  Sam Ravnborg <sam@ravnborg.org>
 *
 *
 * Don't define absolute symbols until and unless you know that symbol
 * value is should remain constant even if kernel image is relocated
 * at run time. Absolute symbols are not relocated. If symbol value should
 * change if kernel is relocated, make the symbol section relative and
 * put it inside the section definition.
 */

#ifdef CONFIG_X86_32
#define LOAD_OFFSET __PAGE_OFFSET
#else
#define LOAD_OFFSET __START_KERNEL_map
#endif

#include <asm-generic/xian.lds.h>
#include <asm/page_types.h>

#ifdef CONFIG_X86_32
OUTPUT_ARCH(i386)
#else
OUTPUT_ARCH(i386:x86-64)
#endif

SECTIONS
{
#ifdef CONFIG_X86_32
        . = LOAD_OFFSET + LOAD_PHYSICAL_ADDR;
        phys_startup_32 = startup_32 - LOAD_OFFSET;
#else
        //这里起始是配置的物理起始地址+2M对齐+内核的虚拟映射
        . = __START_KERNEL;
        phys_startup_64 = startup_64 - LOAD_OFFSET;
#endif

	/* Text and read-only data */
	.text :  AT(ADDR(.text) - LOAD_OFFSET) {
		_text = .;
        HEAD_TEXT
#ifdef CONFIG_X86_32
		. = ALIGN(PAGE_SIZE);
		*(.text..page_aligned)
#endif
		. = ALIGN(8);
		*(.gnu.warning)
		/* End of text section */
		_etext = .;
	} 

	. = ALIGN(16);
	/* Data */
	.data : AT(ADDR(.data) - LOAD_OFFSET) {
		/* Start of data section */
		_sdata = .;

		DATA_DATA

		/* End of data section */
		_edata = .;
	}
	
	/* BSS */
	. = ALIGN(PAGE_SIZE);
	.bss : AT(ADDR(.bss) - LOAD_OFFSET) {
		__bss_start = .;
		*(.bss..page_aligned)
		*(.bss)
		. = ALIGN(PAGE_SIZE);
		__bss_stop = .;
	}

	_end = .;
}