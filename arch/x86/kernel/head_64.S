#include <xian/init.h>

    .text
	__HEAD
	.code64
	.globl startup_64
startup_64:
1:
	hlt
	jmp     1b