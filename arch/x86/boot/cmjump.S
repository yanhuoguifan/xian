
#include <xian/linkage.h>

	.text
	.code32
    
//目的是为了跳到change_mode/head_(bits).S里的
/*
 * void change_mode_jump(u32 entrypoint);
 */
GLOBAL(change_mode_jump)
//	jmpl	*%eax			# Jump to the 32-bit entrypoint
	call die
ENDPROC(change_mode_jump)