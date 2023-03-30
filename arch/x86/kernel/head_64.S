#include <xian/linkage.h>
#include <asm/pgtable.h>
#include <xian/init.h>

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

1:
	hlt
	jmp     1b


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
	 //这里相当于将从0开始KERNEL_IMAGE_SIZE/PMD_SIZE个2M物理页
	 //映射到0xffffffff80000000开始的虚拟地址
	 //__PAGE_KERNEL_LARGE_EXEC : __PAGE_KERNEL_EXEC(_PAGE_PRESENT | _PAGE_RW | \
	 //_PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_GLOBAL) | _PAGE_PSE
	 //KERNEL_IMAGE_SIZE是512m
	PMDS(0, __PAGE_KERNEL_LARGE_EXEC,
		KERNEL_IMAGE_SIZE/PMD_SIZE)

