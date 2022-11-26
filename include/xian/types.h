#ifndef _XIAN_TYPES_H
#define _XIAN_TYPES_H

#include <asm/types.h>

#ifndef __ASSEMBLY__

#include <xian/posix_types.h>

#ifdef __KERNEL__

/*
 * The following typedefs are also protected by individual ifdefs for
 * historical reasons:
 */
#ifndef _SIZE_T
#define _SIZE_T
typedef __kernel_size_t		size_t;
#endif


#endif	/* __KERNEL__ */
#endif /*  __ASSEMBLY__ */
#endif /* end _XIAN_TYPES_H */