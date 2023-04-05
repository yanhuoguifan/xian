#ifndef __XIAN_COMPILER_H
#error "Please don't include <xian/compiler-gcc.h> directly, include <xian/compiler.h> instead."
#endif

#define __aligned(x)			__attribute__((aligned(x)))

#define __always_inline		inline __attribute__((always_inline))