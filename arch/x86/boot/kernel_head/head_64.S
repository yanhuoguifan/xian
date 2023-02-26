	.code32
	.text

#include <xian/linkage.h>
#include <xian/init.h>
#include <asm/boot.h>

    __HEAD
	.code32
ENTRY(startup_32)
	
	//cld:将标志寄存器Flag的方向标志位DF清零
	cld


	/* setup a stack and make sure cpu supports long mode. */
	movl	$boot_stack_end, %esp
	movl	$boot_stack_end, %ebp

    //检测cpu是否支持长模式（64位）和sse，若返回的eax非0，则宕机
	call	verify_cpu
	testl	%eax, %eax
	jnz	no_longmode

no_longmode:
	/* This isn't an x86-64 CPU so hang */
1:
	hlt
	jmp     1b

#include "../../kernel/verify_cpu.S"

	.code64
	.org 0x200
ENTRY(startup_64)

/*
 * Stack for init
 */
	.bss
	.balign 4
boot_stack:
	.fill BOOT_STACK_SIZE, 1, 0
boot_stack_end:

/*
 * Space for page tables (not in .bss so not zeroed)
 */
	.section ".pgtable","a",@nobits
	.balign 4096
pgtable:
	.fill 6*4096, 1, 0