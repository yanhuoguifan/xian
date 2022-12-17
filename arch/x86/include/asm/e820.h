#ifndef _ASM_X86_E820_H
#define _ASM_X86_E820_H
#define E820MAX	128		/* number of entries in E820MAP */

/*
 * Legacy E820 BIOS limits us to 128 (E820MAX) nodes due to the
 * constrained space in the zeropage.  If we have more nodes than
 * that, and if we've booted off EFI firmware, then the EFI tables
 * passed us from the EFI firmware can list more nodes.  Size our
 * internal memory map tables to have room for these additional
 * nodes, based on up to three entries per node for which the
 * kernel was built: MAX_NUMNODES == (1 << CONFIG_NODES_SHIFT),
 * plus E820MAX, allowing space for the possible duplicate E820
 * entries that might need room in the same arrays, prior to the
 * call to sanitize_e820_map() to remove duplicates.  The allowance
 * of three memory map entries per node is "enough" entries for
 * the initial hardware platform motivating this mechanism to make
 * use of additional EFI map entries.  Future platforms may want
 * to allow more than three entries per node or otherwise refine
 * this size.
 */

#define E820_RAM	1
#define E820_RESERVED	2
#define E820_ACPI	3
#define E820_NVS	4
#define E820_UNUSABLE	5

#ifndef __ASSEMBLY__
#include <xian/types.h>

struct e820entry {
	__u64 addr;	/* start of memory segment */
	__u64 size;	/* size of memory segment */
	__u32 type;	/* type of memory segment */
} __attribute__((packed));

#endif /* __ASSEMBLY__ */
#endif /* _ASM_X86_E820_H */