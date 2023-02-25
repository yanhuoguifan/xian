#include "boot.h"

static int parse_elf(void *kernel_file, void** kernel_entry)
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

	memcpy(&ehdr, kernel_file, sizeof(ehdr));
	if (ehdr.e_ident[EI_MAG0] != ELFMAG0 ||
		ehdr.e_ident[EI_MAG1] != ELFMAG1 ||
		ehdr.e_ident[EI_MAG2] != ELFMAG2 ||
		ehdr.e_ident[EI_MAG3] != ELFMAG3) {
		puts("Kernel is not a valid ELF file");
		return -1;
	}

	puts("Parsing ELF of kernel... \n");
	
	phdrs = malloc(sizeof(*phdrs) * ehdr.e_phnum);
	if (!phdrs) {
		puts("Failed to allocate space for phdrs");
		return -1;
	}
	memcpy(phdrs, kernel_file + ehdr.e_phoff, sizeof(*phdrs) * ehdr.e_phnum);

	for (i = 0; i < ehdr.e_phnum; i++) {
		phdr = &phdrs[i];

		switch (phdr->p_type) {
		case PT_LOAD:
#ifdef CONFIG_RELOCATABLE
			dest = kernel_file;
			dest += (phdr->p_paddr - LOAD_PHYSICAL_ADDR);
#else
			dest = (void *)(phdr->p_paddr);
#endif
			memcpy(dest,
			       kernel_file + phdr->p_offset,
			       phdr->p_filesz);
			break;
		default:  break;
		}
	}
	*kernel_entry = (void*)ehdr.e_entry;
	return 0;
}

int load_kernel(void** kernel_entry)
{
    return parse_elf((void*)boot_params.kernel.module_start, kernel_entry);
}
