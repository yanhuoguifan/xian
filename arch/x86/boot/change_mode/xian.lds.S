#include <asm-generic/xian.lds.h>

#undef i386

#ifdef CONFIG_X86_64
OUTPUT_ARCH(i386:x86-64)
#else
OUTPUT_ARCH(i386)
#endif
ENTRY(startup_32)
SECTIONS
{
	/* Be careful parts of head_64.S assume startup_32 is at
	 * address 0x200000.
	 */
	. = 0x200000;
	.head.text : {
		_head = . ;
		HEAD_TEXT
		_ehead = . ;
	}
	.text :	{
		_text = .; 	/* Text */
		*(.text)
		*(.text.*)
		_etext = . ;
	}
	.rodata : {
		_rodata = . ;
		*(.rodata)	 /* read-only data */
		*(.rodata.*)
		_erodata = . ;
	}
	.data :	{
		_data = . ;
		*(.data)
		*(.data.*)
		_edata = . ;
	}
	.bss : {
		_bss = . ;
		*(.bss)
		*(.bss.*)
		*(COMMON)
		. = ALIGN(8);	/* For convenience during zeroing */
		_ebss = .;
	}
	_end = .;
}