#ifndef _XIAN_MEMBLOCK_H
#define _XIAN_MEMBLOCK_H
#ifdef __KERNEL__

#ifdef CONFIG_HAVE_MEMBLOCK
/*
 * Logical memory blocks.
 *
 * Copyright (C) 2001 Peter Bergner, IBM Corp.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version
 * 2 of the License, or (at your option) any later version.
 */
extern void memblock_init(void);

#endif /* CONFIG_HAVE_MEMBLOCK */

#endif /* __KERNEL__ */

#endif /* _XIAN_MEMBLOCK_H */