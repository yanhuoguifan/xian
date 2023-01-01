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

#include "boot.h"

	//multiboot_header必须放在可写可执行的段中，不然grub无法识别
    .section ".header", "a"
	.global _start
_start:
	jmp start_entry


/* Align 64 bits boundary. */
	.align 8
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

address_tag_start:      
        .short MULTIBOOT_HEADER_TAG_ADDRESS
        .short MULTIBOOT_HEADER_TAG_OPTIONAL
        .long address_tag_end - address_tag_start
        /*  header_addr */
        .long   multiboot_header
        /*  load_addr */
        .long   _start
        /*  load_end_addr */
        .long   0
        /*  bss_end_addr */
        .long   _end
address_tag_end:

entry_address_tag_start:        
        .short MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS
        .short MULTIBOOT_HEADER_TAG_OPTIONAL
        .long entry_address_tag_end - entry_address_tag_start
        /*  entry_addr */
        .long start_entry
entry_address_tag_end:

//这里需要8字节对齐
	.align 8
	.short MULTIBOOT_HEADER_TAG_END
	.short 0
	.long 8

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

.globl	hdr
hdr:
	multiboot_addr:	.long 0			/* Filled in by header.S */
	multiboot_magic:	.long 0     /* Filled in by header.S */
	heap_end_ptr:	.long	_end+STACK_SIZE-512

.section ".entrytext" , "ax"
start_entry:

	cli  				//此时还没有设置好保护模式的中断处理，所以必须关闭中断
                       //先保存multiboot的魔数和信息地址
	movl	%ebx, multiboot_addr
	movl	%eax, multiboot_magic
	
	                  //配置内核初始化栈
	movl	heap_end_ptr, %edx
	addl	$STACK_SIZE, %edx
	movl	%edx, %esp
	movl	%edx, %ebp

	calll main

	.globl	die
	.type	die, @function
die:
	hlt             //停机指令，什么也不做，可以降低 CPU 功耗
	jmp	die         //到这里结束，关机什么的后面再说

	.size	die, .-die

