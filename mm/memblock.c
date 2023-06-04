/*
 * Procedures for maintaining information about logical memory blocks.
 *
 * Peter Bergner, IBM Corp.	June 2001.
 * Copyright (C) 2001 Peter Bergner.
 *
 *      This program is free software; you can redistribute it and/or
 *      modify it under the terms of the GNU General Public License
 *      as published by the Free Software Foundation; either version
 *      2 of the License, or (at your option) any later version.
 */

 #include <xian/init.h>

void __init memblock_init(void)
{
    static int init_done __initdata = 0;

	if (init_done)
		return;
	init_done = 1;
}