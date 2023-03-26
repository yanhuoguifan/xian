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


#include <asm-generic/xian.lds.h>
#include <asm/page_types.h>

#ifdef CONFIG_X86_32
OUTPUT_ARCH(i386)
#else
OUTPUT_ARCH(i386:x86-64)
#endif

SECTIONS
{
    . = CONFIG_PHYSICAL_START;

	/* Text and read-only data */
	.text : {
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
}