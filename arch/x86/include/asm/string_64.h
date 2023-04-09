#ifndef _ASM_X86_STRING_64_H
#define _ASM_X86_STRING_64_H

#include <xian/compiler.h>
#include <xian/types.h>

#ifdef __KERNEL__

/* Written 2002 by Andi Kleen */

/* Only used for special circumstances. Stolen from i386/string.h */
static __always_inline void *__inline_memcpy(void *to, const void *from, size_t n)
{
	unsigned long d0, d1, d2;
	asm volatile("rep ; movsl\n\t"
		     "testb $2,%b4\n\t"
		     "je 1f\n\t"
		     "movsw\n"
		     "1:\ttestb $1,%b4\n\t"
		     "je 2f\n\t"
		     "movsb\n"
		     "2:"
		     : "=&c" (d0), "=&D" (d1), "=&S" (d2)
		     : "0" (n / 4), "q" (n), "1" ((long)to), "2" ((long)from)
		     : "memory");
	return to;
}


/* Even with __builtin_ the compiler may decide to use the out of line
   function. */

#define memcpy(dst, src, len) __inline_memcpy((dst), (src), (len))

void *memset(void *s, int c, size_t n);

#endif /* __KERNEL__ */

#endif /* _ASM_X86_STRING_64_H */