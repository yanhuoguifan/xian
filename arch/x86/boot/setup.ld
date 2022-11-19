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
	.text.header		: { *(.text.header) }
	.text.entry			: { *(.text.entry) }

	.data.init          : { *(.data.init) }

	. = ALIGN(16);
	_end = .;
	/*
 	* _end is used for stack
	* There are 2>>9 size space
 	*/
	. = ALIGN(9);
}
