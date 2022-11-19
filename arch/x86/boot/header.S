/* boot.S - bootstrap the kernel */
/* Copyright (C) 1999, 2001, 2010 Free Software Foundation, Inc.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <asm/multiboot.h>
#include "boot.h"

	//似乎必须把头放到text段中，不然qemu或grub无法识别
    .section ".text.header"
	.global _start
_start:
	jmp start_entry

/* Align 64 bits boundary. */
	.align 4
#ifdef CONFIG_MULTIBOOT2

	/* Multiboot header. */
multiboot_header:
	/* magic */
	.long MULTIBOOT2_HEADER_MAGIC
	/* ISA: i386 */
	.long MULTIBOOT_ARCHITECTURE_I386
	/* Header length. */
	.long multiboot_header_end - multiboot_header
	/* checksum */
	.long -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + (multiboot_header_end - multiboot_header))

	.align 4
	.short MULTIBOOT_HEADER_TAG_END
	.short 0
	.long 4

    multiboot_header_end:

#elif CONFIG_MULTIBOOT1

	/* Multiboot header. */
multiboot_header:
	/* magic */
    .long MULTIBOOT_HEADER_MAGIC              	
    .long MULTIBOOT_HEADER_FLAGS
	/* checksum */              	
    .long - (MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)   
multiboot_header_end:

#endif

    .section ".data.init"
	.globl	hdr
hdr:
multiboot_addr:	.long 0			/* Filled in by header.S */
multiboot_magic:	.long 0     /* Filled in by header.S */
heap_end_ptr:	.long	_end+STACK_SIZE-512

    .section ".text.entry"
start_entry:
	cli  				//此时还没有设置好保护模式的中断处理，所以必须关闭中断
	
	movl	heap_end_ptr, %edx
	addl	$STACK_SIZE, %edx
	movl	%edx, %esp
	movl	%edx, %ebp
	sti			# Now we should have a working stack

	calll main

stop:
	hlt 			 //停机指令，什么也不做，可以降低 CPU 功耗
	jmp stop 		 //到这里结束，关机什么的后面再说

    .section ".data.init"
	.globl	hdr
halt_message:
        .asciz  "Halted."