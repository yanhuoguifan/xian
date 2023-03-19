#include "boot.h"

static int parse_elf(void *setup1_file, void** setup1_entry)
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

	memcpy(&ehdr, setup1_file, sizeof(ehdr));
	if (ehdr.e_ident[EI_MAG0] != ELFMAG0 ||
		ehdr.e_ident[EI_MAG1] != ELFMAG1 ||
		ehdr.e_ident[EI_MAG2] != ELFMAG2 ||
		ehdr.e_ident[EI_MAG3] != ELFMAG3) {
		puts("Kernel is not a valid ELF file");
		return -1;
	}

	puts("Parsing ELF of setup1... \n");
	
	phdrs = malloc(sizeof(*phdrs) * ehdr.e_phnum);
	if (!phdrs) {
		puts("Failed to allocate space for phdrs");
		return -1;
	}
	memcpy(phdrs, setup1_file + ehdr.e_phoff, sizeof(*phdrs) * ehdr.e_phnum);

	for (i = 0; i < ehdr.e_phnum; i++) {
		phdr = &phdrs[i];

		switch (phdr->p_type) {
		case PT_LOAD:
			dest = (void *)(phdr->p_paddr);
			memcpy(dest,
			       setup1_file + phdr->p_offset,
			       phdr->p_filesz);
			break;
		default:  break;
		}
	}
	*setup1_entry = (void*)ehdr.e_entry;
	return 0;
}

int load_setup1(void** setup1_entry)
{
    return parse_elf((void*)boot_params.setup1.module_start, setup1_entry);
}
