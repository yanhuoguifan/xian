#ifndef __XIAN_COMPILER_H
#define __XIAN_COMPILER_H

#ifdef __KERNEL__

#ifdef __GNUC__
#include <xian/compiler-gcc.h>
#endif

#ifndef __always_inline
#define __always_inline inline
#endif

#endif /* __KERNEL__ */

/* Simple shorthand for a section definition */
#ifndef __section
# define __section(S) __attribute__ ((__section__(#S)))
#endif

#endif /* __XIAN_COMPILER_H */