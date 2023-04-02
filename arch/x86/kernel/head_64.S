#include <xian/linkage.h>
#include <asm/pgtable.h>
#include <xian/init.h>
#include <asm/processor-flags.h>

//取地址第三级索引
#define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))

//取地址的第四级索引，这里是取了0xffff880000000000的0x880的前9位
L4_PAGE_OFFSET = pgd_index(__PAGE_OFFSET)
//取地址的第四级索引，这里是取了0xffffffff80000000的0xfff的前9位
L4_START_KERNEL = pgd_index(__START_KERNEL_map)
//这里是取了0xffffffff80000000的0xff8的第2位到第10位
L3_START_KERNEL = pud_index(__START_KERNEL_map)

    .text
	__HEAD
	.code64
	.globl startup_64
startup_64:
	
	/*
	 * At this point the CPU runs in 64bit mode CS.L = 1 CS.D = 1,
	 * These identity mapped page tables map all of the
	 * kernel pages and possibly all of memory.
	 *
	 * %esi holds a physical pointer to real_mode_data.
	 */

	/* Compute the delta between the address I am compiled to run at and the
	 * address I am actually running at.
	 */
	 //计算_test的rip相对地址，即当前rip+(虚拟_text-虚拟ip)
	 //由于_test在程序起始，所以实际是真实的起始物理地址
	leaq	_text(%rip), %rbp
	//使用实际物理起始地址当做计算2M对齐的值
	movq    %rbp, %rax
	 //计算虚拟_text-虚拟起始地址，由于_test在程序起始，所以实际是期望的起始物理地址
	 //这个值应该和上面那个值一样，除非内核加载的时候被重定向，偏差值保存在rbp
	subq	$_text - __START_KERNEL_map, %rbp
	/* Fixup phys_base */
	//保存偏差值
	movq	%rbp, phys_base(%rip)

	//内核使用2M大页,x86对齐2M可以提升内存访问效率,减少TLB（Translation Lookaside Buffer）缓存的失效率
	/* Is the address not 2M aligned? */
	andl	$~PMD_PAGE_MASK, %eax
	testl	%eax, %eax
	jnz	bad_address

	/* Is the address too large? */
	//不能超过512G
	leaq	_text(%rip), %rdx
	movq	$PGDIR_SIZE, %rax
	cmpq	%rax, %rdx
	jae	bad_address

	/* Fixup the physical addresses in the page table
	 * 这里到secondary_startup_64都是调整页表
	 */
	addq	%rbp, init_level4_pgt + 0(%rip)
	addq	%rbp, init_level4_pgt + (L4_PAGE_OFFSET*8)(%rip)
	addq	%rbp, init_level4_pgt + (L4_START_KERNEL*8)(%rip)

	addq	%rbp, level3_ident_pgt + 0(%rip)

	addq	%rbp, level3_kernel_pgt + (510*8)(%rip)
	addq	%rbp, level3_kernel_pgt + (511*8)(%rip)

	addq	%rbp, level2_fixmap_pgt + (506*8)(%rip)

	/* Add an Identity mapping if I am above 1G */
	//level2_ident_pgt将虚拟地址0-1G 1:1映射到物理地址,假如真实物理起始地址大于1G，
	//将添加level3_ident_pgt到level2_spare_pgt的映射
	leaq	_text(%rip), %rdi
	//将2M以下的值置零
	andq	$PMD_PAGE_MASK, %rdi

	movq	%rdi, %rax
	//右移39位，_text取1G以上的值
	shrq	$PUD_SHIFT, %rax
	//取0-8位的1
	andq	$(PTRS_PER_PUD - 1), %rax
	//_text在1G以上没有值，跳过添加ident映射
	jz	ident_complete

	leaq	(level2_spare_pgt - __START_KERNEL_map + _KERNPG_TABLE)(%rbp), %rdx
	leaq	level3_ident_pgt(%rip), %rbx
	//相对基址寻址，0(%rbx, %rax, 8)代表0+%rbx+%rax*8对应的地址的内存值
	//这里是将level2_spare_pgt物理地址填入_text的物理地址在1G上对应level3_ident_pgt的项中
	movq	%rdx, 0(%rbx, %rax, 8)

	movq	%rdi, %rax
	shrq	$PMD_SHIFT, %rax
	andq	$(PTRS_PER_PMD - 1), %rax
	//上面得到_text的物理地址在2M以上0-8位的值，即对应的2级目录的项索引
	leaq	__PAGE_KERNEL_IDENT_LARGE_EXEC(%rdi), %rdx
	leaq	level2_spare_pgt(%rip), %rbx
	//填充_text的物理地址对应的level2_spare_pgt项，映射到_text对应的物理页，这里只映射了一个2M的大页
	movq	%rdx, 0(%rbx, %rax, 8)
ident_complete:

	/*
	 * Fixup the kernel text+data virtual addresses. 
	 */

	leaq	level2_kernel_pgt(%rip), %rdi
	leaq	4096(%rdi), %r8

	//这里linux原本会计算level2_kernel_pgt的页项是否可用，对我们来说都是可用的
	//将内核重定向的偏差值加到level2_kernel_pgt的项中
1:	addq	%rbp, 0(%rdi)
	/* Go to the next page */
	addq	$8, %rdi
	cmp	%r8, %rdi
	jne	1b

	//这种直接指定标签，只会获取段内相对地址，跳到的还是物理地址
	jmp secondary_startup_64
ENTRY(secondary_startup_64)
	/*
	 * At this point the CPU runs in 64bit mode CS.L = 1 CS.D = 1,
	 *
	 * %esi holds a physical pointer to real_mode_data.
	 *
	 * We come here either from startup_64 (using physical addresses)
	 */

	/* Enable PAE mode and PGE */
	//PGE是全局页表，它将相同的物理页框映射到所有进程的虚拟地址空间中的相同虚拟地址。
	movl	$(X86_CR4_PAE | X86_CR4_PGE), %eax
	movq	%rax, %cr4

	//将4 level pagetables的实际物理地址加载到cr3中
	/* Setup early boot stage 4 level pagetables. */
	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
	addq	phys_base(%rip), %rax
	movq	%rax, %cr3

	/* Ensure I am executing from virtual addresses */
	movq	$virtual_addresses, %rax
	jmp	*%rax
	
	//从这里进入0xffffffff80000000以上的高位虚拟地址
virtual_addresses:

bad_address:
	hlt
	jmp     bad_address


#define NEXT_PAGE(name) \
	.balign	PAGE_SIZE; \
ENTRY(name)

/* Automate the creation of 1 to 1 mapping pmd entries */
//START表示起始地址，PERM表示权限，COUNT表示需要创建的pmd条目数量
#define PMDS(START, PERM, COUNT)			\
	i = 0 ;						\
	.rept (COUNT) ;					\
	.quad	(START) + (i << PMD_SHIFT) + (PERM) ;	\
	i = i + 1 ;					\
	.endr

	.data
	//这里直接把0xffffffff80000000虚拟地址映射到0x000000物理地址
	//四级页表就48位可以映射256t线性空间，前面的16位只是和第17位相同
	/*
	 * This default setting generates an ident mapping at address 0x100000
	 * and a mapping for the kernel that precisely maps virtual address
	 * 0xffffffff80000000 to physical address 0x000000. (always using
	 * 2Mbyte large pages provided by PAE mode)
	 */

NEXT_PAGE(init_level4_pgt)
	//这里一项映射512g虚拟空间,但实际没有把所有子项都填充完
	//_KERNPG_TABLE:_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED | _PAGE_DIRTY
	//_PAGE_TABLE:_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | _PAGE_ACCESSED | _PAGE_DIRTY
	.quad	level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
	//.org定位数据到偏移值
	.org	init_level4_pgt + L4_PAGE_OFFSET*8, 0
	.quad	level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
	.org	init_level4_pgt + L4_START_KERNEL*8, 0
	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
	//这里定位到最后一项
	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE

NEXT_PAGE(level3_ident_pgt)
	.quad	level2_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
	.fill	511,8,0

NEXT_PAGE(level3_kernel_pgt)
	//实际填充了510个空项
	.fill	L3_START_KERNEL,8,0
	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
	.quad	level2_kernel_pgt - __START_KERNEL_map + _KERNPG_TABLE
	.quad	level2_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE

NEXT_PAGE(level2_fixmap_pgt)
	.fill	506,8,0
	.quad	level1_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
	/* 8MB reserved for vsyscalls + a 2MB hole = 4 + 1 entries */
	.fill	5,8,0

//可以看到，这是一个空表，初始化时没有指向任何一个物理页
NEXT_PAGE(level1_fixmap_pgt)
	.fill	512,8,0

NEXT_PAGE(level2_ident_pgt)
	/* Since I easily can, map the first 1G.
	 * Don't set NX because code runs from these pages.
	 */
	//实际将虚拟地址的0-1G映射到物理地址0-1G
	//__PAGE_KERNEL_IDENT_LARGE_EXEC == __PAGE_KERNEL_LARGE_EXEC
	PMDS(0, __PAGE_KERNEL_IDENT_LARGE_EXEC, PTRS_PER_PMD)

//存放内核本身
NEXT_PAGE(level2_kernel_pgt)
	/*
	 * 512 MB kernel mapping. We spend a full page on this pagetable
	 * anyway.
	 *
	 * The kernel code+data+bss must not be bigger than that.
	 *
	 * (NOTE: at +512MB starts the module area, see MODULES_VADDR.
	 *  If you want to increase this then increase MODULES_VADDR
	 *  too.)
	 */
	 //这里相当于将从0开始(实际后面会修正添加偏差值)KERNEL_IMAGE_SIZE/PMD_SIZE个2M物理页
	 //映射到0xffffffff80000000开始的虚拟地址
	 //__PAGE_KERNEL_LARGE_EXEC : __PAGE_KERNEL_EXEC(_PAGE_PRESENT | _PAGE_RW | \
	 //_PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_GLOBAL) | _PAGE_PSE
	 //KERNEL_IMAGE_SIZE是512m
	PMDS(0, __PAGE_KERNEL_LARGE_EXEC,
		KERNEL_IMAGE_SIZE/PMD_SIZE)

NEXT_PAGE(level2_spare_pgt)
	.fill   512, 8, 0

ENTRY(phys_base)
	/* This must match the first entry in level2_kernel_pgt */
	.quad   0x0000000000000000

