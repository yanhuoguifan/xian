/*
 * setup.ld
 *
 * Linker script for the i386 setup code
 */
OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS
{
	. = 0x100000;
	
	.header		: { *(.header) }
	.entrytext  : { *(.entrytext) }
	.inittext	: { *(.inittext) }

	. = ALIGN(16);
	
	.text		: { *(.text) }

	.rodata		: { *(.rodata*) }
	
	. = ALIGN(16);
	.data		: { *(.data*) }

	. = ALIGN(16);
	.bss		:
	{
		__bss_start = .;
		*(.bss)
		__bss_end = .;
	}

	. = ALIGN(16);
	_end = .;
	/*
 	* _end is used for stack
	* There are 2>>9 size space
 	*/
	. = ALIGN(9);
}
