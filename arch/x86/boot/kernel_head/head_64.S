	.code32
	.text

#include <xian/init.h>
#include <xian/linkage.h>
#include <asm/segment.h>
#include <asm/boot.h>
#include <asm/msr.h>
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

	/* Enable Long mode in EFER (Extended Feature Enable Register) */
	//把 MSR_EFER（0xc0000080）放到 ecx 寄存器中，然后调用 rdmsr 指令读取 MSR 寄存器。
	//在 rdmsr 执行之后，我们将会获得 edx:eax 中的结果值，其取决于 ecx 的值。
	//我们通过 btsl 指令取反 EFER_LME 位，并且通过 wrmsr 指令将 eax 的数据写入 MSR 寄存器。
	movl	$MSR_EFER, %ecx
	rdmsr
	btsl	$_EFER_LME, %eax
	wrmsr

	/*
	 * Setup for the jump to 64bit mode
	 *
	 * When the jump is performend we will be in long mode but
	 * in 32bit compatibility mode with EFER.LME = 1, CS.L = 0, CS.D = 1
	 * (and in turn EFER.LMA = 1).	To jump into 64bit mode we use
	 * the new gdt/idt that has __KERNEL_CS with CS.L = 1.
	 * 使用长跳转从32位进入64位
	 */

	/* Enter paged protected Mode, activating Long Mode */
	movl	$(X86_CR0_PG | X86_CR0_PE), %eax /* Enable Paging and Protected mode */
	movl	%eax, %cr0

	//使用长跳刷新CS段寄存器
	jmp $__KERNEL_CS, $startup_64
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

	/* Setup data segments. */
	//由于x64再64位模式下不再使用大部分数据段描述符，故置位0
	xorl	%eax, %eax
	movl	%eax, %ds
	movl	%eax, %es
	movl	%eax, %ss
	movl	%eax, %fs
	movl	%eax, %gs
	//lldt加载局部描述符表，这里相当于不使用局部描述符表
	lldt	%ax

	/* Zero EFLAGS */
	//1.可以清除之前的标志位
	//2.禁止中断（IF位）
	//3.禁止调度器（TF位）
	//4.初始化EFLAGS寄存器
	pushq	$0
	popfq

/*
 * Jump to the text address.
 * 避免后续.head.text与text段不在相邻导致问题，这里使用跳转进入text代码段
 */
	leaq	text_head, %rax
	jmp	*%rax

	.text
text_head:

/*
 * Clear BSS (stack is currently empty)
 */
	xorl	%eax, %eax
	leaq    _bss(%rip), %rdi
	leaq    _ebss(%rip), %rcx
	//将 rcx 减去 rdi，得到 BSS 段的大小。
	subq	%rdi, %rcx
	//将 rcx 右移三位，相当于除以 8，计算出要清零的 quadword 数量。
	shrq	$3, %rcx
	rep	stosq

1:
	hlt
	jmp     1b


	.data
gdt:
	.word	gdt_end - gdt
	.long	gdt
	.word	0
	.quad	0x0000000000000000	/* NULL descriptor */
	//CS.L = 1 CS.D = 0
	.quad	0x00af9a000000ffff	/* __KERNEL_CS */
	//实际上__KERNEL_DS不再起作用了
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