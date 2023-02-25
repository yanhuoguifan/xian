	.code32
	.text

#include <xian/linkage.h>
#include <xian/init.h>

    __HEAD
	.code32
ENTRY(startup_32)

    hlt
	jmp  startup_32

	.code64
	.org 0x200
ENTRY(startup_64)