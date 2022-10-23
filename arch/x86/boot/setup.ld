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
	.text :
	{
		*(.text)
	  	. = ALIGN(32);
	}
	.entrytext :
	{
		*(.entrytext)
	  	. = ALIGN(4096);
	}

}
