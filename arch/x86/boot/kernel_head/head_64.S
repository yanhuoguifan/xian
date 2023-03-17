	.code32
	.text

#include <xian/linkage.h>
#include <xian/init.h>
#include <asm/boot.h>
#include <asm/processor-flags.h>

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

/*
 * Prepare for entering 64 bit mode
 */

	/* Load new GDT with the 64bit segments using 32bit descriptor */
	leal	gdt, %eax
	movl	%eax, gdt+2
	lgdt	gdt

	/* Enable PAE mode */
	movl	$(X86_CR4_PAE), %eax
	movl	%eax, %cr4

 /*
  * Build early 4G boot pagetable
  * 以下效果是0-4G虚拟地址直接转换成0-4G物理地址
  */
	/* Initialize Page tables to 0 */
	leal	pgtable, %edi
	xorl	%eax, %eax
	movl	$((4096*6)/4), %ecx
	rep	stosl

	/* Build Level 4 */
	//填了一个PML4TE，指向下一页
	leal	pgtable, %edi
	//0x0007 : PRESENT+RW+USER
	//0x1000 : PDP的地址偏移
	leal	0x1007 (%edi), %eax
	movl	%eax, 0(%edi)

	/* Build Level 3 */
	//填了四个PDPTE，分别指向后四页
	leal	pgtable + 0x1000, %edi
	//0x0007 : PRESENT+RW+USER
	//0x1000 : PDP的地址偏移
	leal	0x1007(%edi), %eax
	movl	$4, %ecx
1:	movl	%eax, 0x00(%edi)
	addl	$0x00001000, %eax
	addl	$8, %edi
	decl	%ecx
	jnz	1b

	/* Build Level 2 */
	//填了2048个PDE，分别指向从0开始的2048个2M页
	leal	pgtable + 0x2000, %edi
	//0x183->110000011 : Present+RW+PS+PAT
	movl	$0x00000183, %eax
	movl	$2048, %ecx
1:	movl	%eax, 0(%edi)
	addl	$0x00200000, %eax
	addl	$8, %edi
	decl	%ecx
	jnz	1b

	/* Enable the boot page tables */
	leal	pgtable, %eax
	movl	%eax, %cr3

ENDPROC(startup_32)

no_longmode:
	/* This isn't an x86-64 CPU so hang */
1:
	hlt
	jmp     1b

#include "../../kernel/verify_cpu.S"

	.code64
	.org 0x200
ENTRY(startup_64)

	.data
gdt:
	.word	gdt_end - gdt
	.long	gdt
	.word	0
	.quad	0x0000000000000000	/* NULL descriptor */
	//CS.L = 1 CS.D = 0
	.quad	0x00af9a000000ffff	/* __KERNEL_CS */
	.quad	0x00cf92000000ffff	/* __KERNEL_DS */
	.quad	0x0080890000000000	/* TS descriptor */
	.quad   0x0000000000000000	/* TS continued */
gdt_end:

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