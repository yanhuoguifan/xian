/* Written 2000 by Andi Kleen */
#ifndef _ASM_X86_DESC_DEFS_H
#define _ASM_X86_DESC_DEFS_H

/*
 * Segment descriptor structure definitions, usable from both x86_64 and i386
 * archs.
 */

#ifndef __ASSEMBLY__

#include <xian/types.h>

/*
 * FIXME: Accessing the desc_struct through its fields is more elegant,
 * and should be the one valid thing to do. However, a lot of open code
 * still touches the a and b accessors, and doing this allow us to do it
 * incrementally. We keep the signature as a struct, rather than an union,
 * so we can get rid of it transparently in the future -- glommer
 */
/* 8 byte segment descriptor */
struct desc_struct {
	union {
		struct {
			unsigned int a;
			unsigned int b;
		};
		struct {
			u16 limit0;
			u16 base0;
			unsigned base1: 8, type: 4, s: 1, dpl: 2, p: 1;
			unsigned limit: 4, avl: 1, l: 1, d: 1, g: 1, base2: 8;
		};
	};
} __attribute__((packed));

#define GDT_ENTRY_INIT(flags, base, limit) { { { \
		.a = ((limit) & 0xffff) | (((base) & 0xffff) << 16), \
		.b = (((base) & 0xff0000) >> 16) | (((flags) & 0xf0ff) << 8) | \
			((limit) & 0xf0000) | ((base) & 0xff000000), \
	} } }

#endif /* !__ASSEMBLY__ */

#endif /* _ASM_X86_DESC_DEFS_H */