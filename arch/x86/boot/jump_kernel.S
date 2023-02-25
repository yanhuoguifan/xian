
#include <xian/linkage.h>

	.text
	.code32
    
//目的是为了跳到change_mode/head_(bits).S里的
/*
 * void jump_kernel(u32 entrypoint);
 */
GLOBAL(jump_kernel)
//	jmpl	*%eax			# Jump to the 32-bit entrypoint
	call die
ENDPROC(jump_kernel)