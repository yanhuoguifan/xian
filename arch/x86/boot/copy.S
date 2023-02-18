/* ----------------------------------------------------------------------- *
 *
 *   Copyright (C) 1991, 1992 Linus Torvalds
 *   Copyright 2007 rPath, Inc. - All Rights Reserved
 *
 *   This file is part of the xian kernel, and is made available under
 *   the terms of the GNU General Public License version 2.
 *
 * ----------------------------------------------------------------------- */

#include <xian/linkage.h>

/*
 * Memory copy routines
 */
/*
可以参考这边文章https://blog.csdn.net/qq_39679797/article/details/124507307
*/
GLOBAL(memcpy)
	pushl	%esi
	pushl	%edi
	movl	%eax, %edi
	movl	%edx, %esi
	pushl	%ecx
	shrl	$2, %ecx
	rep; movsl
/*
上面是四字节为单位拷贝
下面是一字节为单位拷贝
*/
	popl	%ecx
	andl	$3, %ecx
	rep; movsb
	popl	%edi
	popl	%esi
	ret
ENDPROC(memcpy)