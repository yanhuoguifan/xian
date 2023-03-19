#include <asm-generic/xian.lds.h>

#include <asm/page_types.h>

#ifdef CONFIG_X86_64
OUTPUT_ARCH(i386:x86-64)
#else
OUTPUT_ARCH(i386)
#endif
ENTRY(startup_32)
SECTIONS
{
	/* Be careful parts of head_64.S assume startup_32 is at
	 * CONFIG_SETUP1_START,default 0x200000.
	 */
	. = CONFIG_SETUP1_START;
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
#ifdef CONFIG_X86_64
       . = ALIGN(PAGE_SIZE);
       .pgtable : {
		_pgtable = . ;
		*(.pgtable)
		_epgtable = . ;
	}
#endif
	_end = .;
}