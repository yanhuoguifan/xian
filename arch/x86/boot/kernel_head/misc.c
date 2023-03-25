#include "misc.h"

#define STATIC		static

struct boot_params *real_mode;		/* Pointer to real-mode data */

static memptr free_mem_ptr;
static memptr free_mem_end_ptr;

#include <xian/kernel_head/mm.h>

#ifdef CONFIG_X86_32
void *memcpy(void *dest, const void *src, size_t n)
{
	int d0, d1, d2;
	asm volatile(
		"rep ; movsl\n\t"
		"movl %4,%%ecx\n\t"
		"rep ; movsb\n\t"
        //输出变量
        //"=&c" (d0)：将计数器（ecx）设置为d0的值。独占寄存器
        //"=&D" (d1)：目标地址寄存器（edi），将目标地址指定为d1的值。独占寄存器
        //"=&S" (d2)：源地址寄存器（esi），将源地址指定为d2的值。独占寄存器
		: "=&c" (d0), "=&D" (d1), "=&S" (d2)
        //输入变量
        //"0" (n >> 2)：指定要复制的双字数量，将其赋值给第0个输出寄存器ecx。
        //"g" (n & 3)：指定要复制的剩余字节数，赋值给任意内存或寄存器
        //"1" (dest)：将目标地址传递给输出变量“=&D”（d1）。
        //"2" (src)：将源地址传递给输出变量“=&S”（d2）。
		: "0" (n >> 2), "g" (n & 3), "1" (dest), "2" (src)
        //内存约束（"memory"）来指示汇编代码可能会影响任何内存位置
		: "memory");

	return dest;
}
#else
void *memcpy(void *dest, const void *src, size_t n)
{
	long d0, d1, d2;
	asm volatile(
		"rep ; movsq\n\t"
		"movq %4,%%rcx\n\t"
		"rep ; movsb\n\t"
		: "=&c" (d0), "=&D" (d1), "=&S" (d2)
		: "0" (n >> 3), "g" (n & 7), "1" (dest), "2" (src)
		: "memory");

	return dest;
}
#endif

void move_kernel(struct module *kernel, unsigned char *output)
{
    //实际这个拷贝没有意义，只是为了后面重定向内核做准备
    memcpy((void*)output, (const void *)kernel->module_start, kernel->module_len);
}

static void error(char *x)
{
	puts("\n\n");
	puts(x);
	puts("\n\n -- System halted");

	while (1)
		asm("hlt");
}

static void parse_elf(void *output)
{
#ifdef CONFIG_X86_64
	Elf64_Ehdr ehdr;
	Elf64_Phdr *phdrs, *phdr;
#else
	Elf32_Ehdr ehdr;
	Elf32_Phdr *phdrs, *phdr;
#endif
	void *dest;
	int i;

	memcpy(&ehdr, output, sizeof(ehdr));
	if (ehdr.e_ident[EI_MAG0] != ELFMAG0 ||
	   ehdr.e_ident[EI_MAG1] != ELFMAG1 ||
	   ehdr.e_ident[EI_MAG2] != ELFMAG2 ||
	   ehdr.e_ident[EI_MAG3] != ELFMAG3) {
		error("Kernel is not a valid ELF file");
		return;
	}

	phdrs = malloc(sizeof(*phdrs) * ehdr.e_phnum);
	if (!phdrs)
		error("Failed to allocate space for phdrs");

	memcpy(phdrs, output + ehdr.e_phoff, sizeof(*phdrs) * ehdr.e_phnum);
	for (i = 0; i < ehdr.e_phnum; i++) {
		phdr = &phdrs[i];

		switch (phdr->p_type) {
		case PT_LOAD:
			dest = (void *)(phdr->p_paddr);
			memcpy(dest,
			       output + phdr->p_offset,
			       phdr->p_filesz);
			break;
		default: /* Ignore other PT_* */ break;
		}
	}
}

void load_kernel(void *rmode, memptr heap, unsigned char *output)
{
    real_mode = rmode;

    console_init();
    puts("early console in load_kernel\n");

    free_mem_ptr     = heap;	/* Heap */
	free_mem_end_ptr = heap + BOOT_HEAP_SIZE;

    move_kernel(&real_mode->kernel, output);
    puts("move kernel\n");

    parse_elf(output);
    puts("done.\nBooting the kernel.\n");
    return;
}